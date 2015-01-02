//
//  MAVEPreFetchedHTTPRequest.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import "MAVEPendingResponseData.h"
#import "MaveSDK.h"
#import "MAVEHTTPManager.h"

@implementation MAVEPendingResponseData

- (instancetype)initWithDefaultData:(NSDictionary *)defaultResponseData {
    if (self = [self init]) {
        _defaultData = defaultResponseData;
        _responseData = defaultResponseData;
        self.gcd_semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)setResponseData:(NSDictionary *)responseData {
    _responseData = responseData;
    dispatch_semaphore_signal(self.gcd_semaphore);
}

// Aborts the response, we'll just use the default data
- (void)doNotSetResponseData {
    dispatch_semaphore_signal(self.gcd_semaphore);
}

- (void)readDataWithTimeout:(float)seconds
            completionBlock:(void (^)(NSDictionary * responseData, NSDictionary * defaultData))completionBlock {
    // Run whole method in a background thread because it might block
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // block until request returned or timeout
        NSInteger waitVal = dispatch_semaphore_wait(self.gcd_semaphore, seconds * NSEC_PER_SEC);
        
        // Return data. If request has returned in time, this will be the response data.
        // Otherwise this is the default dataf
        completionBlock(self.responseData, self.defaultData);
        
        // Re-wake the semaphore in case anyone else is waiting on it
        // if we returned without a timeout
        if (waitVal == 0) {
            dispatch_semaphore_signal(self.gcd_semaphore);
        }
    });
}

@end
