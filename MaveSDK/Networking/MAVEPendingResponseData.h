//
//  MAVEPendingResponseData.h
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//  Helper for asynchronously dealing with GET request dictionary data,
//  lets you specify a default return value.
//
//  You use it by calling the read data with timeout method. If the
//  setResponseData method gets called before the timeout that data
//  is returned, otherwise the default data is.
//

#import <Foundation/Foundation.h>

@interface MAVEPendingResponseData : NSObject

@property dispatch_semaphore_t gcd_semaphore;
@property (nonatomic, strong) NSDictionary *defaultData;
@property (nonatomic, strong) NSDictionary *responseData;

// NB: These objects should be created via the preFetch* methods in the HTTPManager
// which handle the request route, parameters, authentication, etc.
- (instancetype)initWithDefaultData:(NSDictionary *)defaultResponseData;
- (void)setResponseData:(NSDictionary *)responseData;
- (void)doNotSetResponseData;

// Read asynchronously and process data in a block.
// The response data will be the default data if the timeout was hit, but default data is still
// returned as separate parameter so you can access it in both the timeout and non-timeout cases.
- (void)readDataWithTimeout:(float)timeout
            completionBlock:(void(^)(NSDictionary *responseData, NSDictionary *defaultData))completionBlock;

@end
