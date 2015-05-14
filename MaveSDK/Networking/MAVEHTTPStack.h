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

#import <UIKit/UIKit.h>

typedef void (^MAVEHTTPCompletionBlock)(NSError *error, NSDictionary *responseData);

// Encoding for the request body.
// GET and DELETE requests don't have a body so it doesn't apply to them
typedef NS_ENUM(NSInteger, MAVEHTTPRequestContentEncoding) {
    // Default is regular UTF-8 encoding, which will be the plain json string for json requests
    MAVEHTTPRequestContentEncodingDefault,
    MAVEHTTPRequestContentEncodingGzip,
};


@interface MAVEHTTPStack : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) void (^requestLoggingBlock)(NSString *value);

- (instancetype)initWithAPIBaseURL:(NSString *)baseURL;


- (NSMutableURLRequest *)prepareJSONRequestWithRoute:(NSString *)relativeURL
                                          methodName:(NSString *)methodName
                                              params:(id)params
                                     contentEncoding:(MAVEHTTPRequestContentEncoding)contentEncoding
                                    preparationError:(NSError **)preparationError;
- (void)sendPreparedRequest:(NSURLRequest *)request
            completionBlock:(MAVEHTTPCompletionBlock)completionBlock;
- (void)handleJSONResponseWithData:(NSData *)data
                          response:(NSURLResponse *)response
                             error:(NSError *)error
                   completionBlock:(MAVEHTTPCompletionBlock)completionBlock;
+ (NSString *)dictToURLQueryStringFragment:(NSDictionary *)dict;
+ (NSInteger)statusCodeLevel:(NSInteger)code;

// Common tasks
- (void)fetchImageFromURL:(NSURL *)absoluteURL completionBlock:(void (^)(UIImage *image))completionBlock;

@end
