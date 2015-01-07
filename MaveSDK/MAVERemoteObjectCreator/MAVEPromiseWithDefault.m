//
//  MAVEPromiseWithDefault.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import "MAVEPromiseWithDefault.h"
#import "MAVEPromiseWithDefault_Internal.h"

@implementation MAVEPromiseWithDefault {
    NSValue *_defaultValue;
    NSValue *_fulfilledValue;
}

- (instancetype)initWithDefaultValue:(NSValue *)defaultValue {
    if (self = [super init]) {
        _defaultValue = defaultValue;
        _status = MAVEPromiseStatusUnfulfilled;
        _fulfilledValue = nil;
        self.gcd_semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (NSValue *)defaultValue {
    return _defaultValue;
}
- (void)setDefaultValue:(NSValue *)defaultValue {
    _defaultValue = defaultValue;
}

- (NSValue *)fulfilledValue {
    return _fulfilledValue;
}
- (void)setFulfilledValue:(NSValue *)fulfilledValue {
    _fulfilledValue = fulfilledValue;
    _status = MAVEPromiseStatusFulfilled;
    dispatch_semaphore_signal(self.gcd_semaphore);
}

- (void)rejectPromise {
    _status = MAVEPromiseStatusRejected;
    dispatch_semaphore_signal(self.gcd_semaphore);
}

- (void)valueWithTimeout:(float)seconds
         completionBlock:(void (^)(NSValue *))completionBlock {
    // Run whole method in a background thread because it might block
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // block until request returned or timeout
        NSInteger waitVal = dispatch_semaphore_wait(self.gcd_semaphore, seconds * NSEC_PER_SEC);

        if (self.status == MAVEPromiseStatusFulfilled) {
            completionBlock(_fulfilledValue);
        } else {
            completionBlock(_defaultValue);
        }

        // If we returned without a timeout re-wake the semaphore in case anyone else is waiting
        if (waitVal == 0) {
            dispatch_semaphore_signal(self.gcd_semaphore);
        }
    });
}

@end


@implementation MAVEPromiseWithDefaultDictValues

- (instancetype)initWithDefaultValue:(NSDictionary *)defaultValue {
    return [super initWithDefaultValue:(NSValue *)defaultValue];
}

- (NSDictionary *)fulfilledValue {
    return (NSDictionary *)[super fulfilledValue];
}
- (void)setFulfilledValue:(NSDictionary *)fulfilledValue {
    [super setFulfilledValue:(NSValue *)fulfilledValue];
}

- (NSDictionary *)defaultValue {
    return (NSDictionary *)[super defaultValue];
}
- (void) setDefaultValue:(NSDictionary *)defaultValue {
    [super setDefaultValue:(NSValue *)defaultValue];
}

- (void)valueWithTimeout:(float)seconds
         completionBlock:(void (^)(NSDictionary *))completionBlock {
    [super valueWithTimeout:seconds completionBlock:^(NSValue *value) {
            completionBlock((NSDictionary *)value);
    }];
}

@end
