//
//  MAVEHTTPStack.h
//  MaveSDK
//
//
//  Foundation for http requests that we'll make from the client to our API.
//  Adds  helper functions and REST api semantics to make use of (JSON serialization & deserialization,
//  GET request parameters, etc.) beyond what NSURLSession provides, and sets up our request queue.
//  Created by Danny Cosson on 1/2/15.
//

#import <Foundation/Foundation.h>

typedef void (^MAVEHTTPCompletionBlock)(NSError *error, NSDictionary *responseData);



@interface MAVEHTTPStack : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *baseURL;

- (instancetype)initWithAPIBaseURL:(NSString *)baseURL;


- (NSMutableURLRequest *)prepareJSONRequestWithRoute:(NSString *)relativeURL
                                          methodName:(NSString *)methodName
                                              params:(NSDictionary *)params
                                    preparationError:(NSError **)preparationError;
- (void)sendPreparedRequest:(NSURLRequest *)request
            completionBlock:(MAVEHTTPCompletionBlock)completionBlock;
- (void)handleJSONResponseWithData:(NSData *)data
                          response:(NSURLResponse *)response
                             error:(NSError *)error
                   completionBlock:(MAVEHTTPCompletionBlock)completionBlock;
+ (NSString *)dictToURLQueryStringFragment:(NSDictionary *)dict;
+ (NSInteger)statusCodeLevel:(NSInteger)code;

@end
