//
//  MAVEPromise.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import "MAVEPromise.h"
#import "MAVEPromise_Internal.h"

@implementation MAVEPromise

- (instancetype)initWithBlock:(void (^)(MAVEPromise *))runBlock {
    if (self = [super init]) {
        self.status = MAVEPromiseStatusUnfulfilled;
        self.value = nil;
        self.gcd_semaphore = dispatch_semaphore_create(0);
        if (runBlock) {
            runBlock(self);
        }
    }
    return self;
}

#pragma mark - Fulfill and reject methods

- (void)fulfillPromise:(NSValue *)value {
    self.value = value;
    self.status = MAVEPromiseStatusFulfilled;
    dispatch_semaphore_signal(self.gcd_semaphore);
}

- (void)rejectPromise {
    self.status = MAVEPromiseStatusRejected;
    dispatch_semaphore_signal(self.gcd_semaphore);
}


# pragma mark - Done, and Then methods to get data

- (NSValue *)doneSynchronousWithTimeout:(CGFloat)seconds {
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    NSInteger waitVal = dispatch_semaphore_wait(self.gcd_semaphore, interval);
    // If we returned without a timeout re-wake the semaphore in case anyone else is waiting
    if (waitVal == 0) {
        dispatch_semaphore_signal(self.gcd_semaphore);
    }

    return self.value;
}

- (void)done:(void (^)(NSValue *))completionBlock withTimeout:(CGFloat)seconds {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSValue *val = [self doneSynchronousWithTimeout:seconds];
        completionBlock(val);
    });
}

@end
