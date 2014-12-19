//
//  MAVEPreFetchedHTTPRequest.h
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//  Helper for pre-emptively doing a GET request from our platform API.
//  Has a method to start the request with a default response if it times
//  out, then a method that takes a block to process the json rsponse with
//  a timeout that if hit will return immediately with the default response.
//

#import <Foundation/Foundation.h>

@interface MAVEPreFetchedHTTPRequest : NSObject

@property (atomic) BOOL requestComplete;
@property dispatch_semaphore_t gcd_semaphore;
@property (nonatomic, strong) NSDictionary *responseData;

- (instancetype)initWithDefaultData:(NSDictionary *)defaultResponseData;
- (void)setResponseData:(NSDictionary *)responseData;
- (void)doNotSetResponseData;

- (void)readDataWithTimeout:(float)timeout completionBlock:(void(^)(NSDictionary *responseData))completionBlock;

@end
