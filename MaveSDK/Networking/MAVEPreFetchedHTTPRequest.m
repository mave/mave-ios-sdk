//
//  MAVEPreFetchedHTTPRequest.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import "MAVEPreFetchedHTTPRequest.h"
#import "MaveSDK.h"
#import "MAVEHTTPManager_Internal.h"

@implementation MAVEPreFetchedHTTPRequest

- (instancetype)initWithDefaultData:(NSDictionary *)defaultResponseData {
    if (self = [self init]) {
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

- (void)readDataWithTimeout:(float)seconds completionBlock:(void (^)(NSDictionary *))completionBlock {
    // block until request returned or timeout
    NSInteger waitVal = dispatch_semaphore_wait(self.gcd_semaphore, seconds * NSEC_PER_SEC);
    
    // Return data. If request has returned in time, this will be the response data.
    // Otherwise this is the default dataf
    completionBlock(self.responseData);

    // Re-wake the semaphore in case anyone else is waiting on it
    // if we returned without a timeout
    if (waitVal == 0) {
        dispatch_semaphore_signal(self.gcd_semaphore);
    }
}

@end
