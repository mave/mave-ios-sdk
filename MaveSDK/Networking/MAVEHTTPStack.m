//
//  MAVEHTTPStack.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/2/15.
//
//

#import "MAVEHTTPStack.h"
#import "MAVEConstants.h"

@implementation MAVEHTTPStack

- (instancetype)initWithAPIBaseURL:(NSString *)baseURL {
    if (self = [self init]) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = 10.0;
        sessionConfig.timeoutIntervalForResource = 10.0;
        
        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:delegateQueue];
        
        self.baseURL = baseURL;
    }
    return self;
}

///
/// Formatting requests and responses
///
- (NSMutableURLRequest *)prepareJSONRequestWithRoute:(NSString *)relativeURL
                                          methodName:(NSString *)methodName
                                              params:(NSDictionary *)params
                                    preparationError:(NSError **)preparationError {
    NSData *bodyData;
    // For GET request, turn params into querystring params
    if ([methodName isEqualToString:@"GET"]) {
        relativeURL = [relativeURL stringByAppendingString:
                       [[self class] dictToURLQueryStringFragment:params]];
        bodyData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        // Parse JSON for body and handle errors
        NSError *jsonParseError;
        if ([NSJSONSerialization isValidJSONObject:params]) {
            NSError *jsonSerializationError;
            bodyData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&jsonSerializationError];
            if (jsonSerializationError != nil) {
                NSDictionary *userInfo = @{};
                jsonParseError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN
                                                            code:MAVEHTTPErrorRequestJSONCode
                                                        userInfo:userInfo];
            }
        } else {
            NSDictionary *userInfo = @{};
            jsonParseError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN
                                                        code:MAVEHTTPErrorRequestJSONCode
                                                    userInfo:userInfo];
        }
        if (jsonParseError != nil) {
            *preparationError = jsonParseError;
            return nil;
        }
    }
    
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString:relativeURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:methodName];
    [request setHTTPBody:bodyData];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

- (void)handleJSONResponseWithData:(NSData *)data
                          response:(NSURLResponse *)response
                             error:(NSError *)error
                   completionBlock:(MAVEHTTPCompletionBlock)completionBlock {
    // If Nil completion block, it was a fire and forget type request
    // so we don't need to handle the response at all
    if (completionBlock == nil) {
        return;
    }
    
    // Handle nil response
    if (response == nil) {
        NSError *nilResponseError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN
                                                               code:MAVEHTTPErrorResponseNilCode
                                                           userInfo:@{}];
        return completionBlock(nilResponseError, nil);
    }
    
    // Handle error codes
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    // handle 4xx or 5xx level status codes
    if (statusCode / 100 == 4 || statusCode / 100 == 5) {
        NSError *statusCodeError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN
                                                              code:statusCode
                                                          userInfo:@{}];
        return completionBlock(statusCodeError, nil);
    }
    
    // Handle formatting & displaying response
    NSError *returnError;
    NSDictionary *returnDict;
    NSString *contentType = [httpResponse.allHeaderFields valueForKey:@"Content-Type"];
    if ([contentType isEqualToString: @"application/json"]) {
        
        // JSON empty data might be a string literal ""
        NSString *dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (data ==nil ||
            data.length == 0 ||
            [dataAsString isEqualToString:@"\"\"\n"]) {
            returnError = nil;
            returnDict = @{};
        } else {
            NSError *serializationError;
            returnDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&serializationError];
            if (serializationError != nil) {
                MAVEDebugLog(@"Bad JSON error: %@", data);
                returnError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN
                                                         code:MAVEHTTPErrorResponseJSONCode
                                                     userInfo:@{}];
            }
        }
    } else {
        returnError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN
                                                 code:MAVEHTTPErrorResponseIsNotJSONCode
                                             userInfo:@{}];
    }
    return completionBlock(returnError, returnDict);
}

- (void)sendPreparedRequest:(NSURLRequest *)request
            completionBlock:(MAVEHTTPCompletionBlock)completionBlock {
    // Send request
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request
                    completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        MAVEDebugLog(@"HTTP Request: \"%lu\" %@ %@", (long)((NSHTTPURLResponse *)response).statusCode, request.HTTPMethod, request.URL);
        [self handleJSONResponseWithData:data
                                response:response
                                   error:error
                         completionBlock:completionBlock];
    }];
    [task resume];
}

///
/// Conversion Util methods
///
+ (NSString *)dictToURLQueryStringFragment:(NSDictionary *)dict {
    if ([dict count] == 0) {
        return @"";
    }
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *fragments = [[NSMutableArray alloc] init];
    NSString *key, *val;
    for (key in sortedKeys) {
        val = [dict objectForKey:key];
        if (val == (id)[NSNull null]) {  // NSNull and all false-ey things
            val = @"";
        }
        // convert non-strings to strings
        val = [NSString stringWithFormat:@"%@", val];
        val = [val stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [fragments addObject:[NSString stringWithFormat:@"%@=%@", key, val]];
    }
    return [@"?" stringByAppendingString:[fragments componentsJoinedByString:@"&"]];
}

+ (NSInteger)statusCodeLevel:(NSInteger)code {
    return code / 100;
}

///
/// Redirects
///
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler {
    // Always redirect with the same method, body, headers as original request
    //
    // NB: Default behavior in all HTTP clients including this one is
    // for same method to be used unless it's POST in which case it gets
    // changed to GET, and for request body to always be dropped.
    // We want to be able to redirect seamlessly
    NSMutableURLRequest *newRequest =
    [[NSMutableURLRequest alloc] initWithURL:request.URL
                                 cachePolicy:request.cachePolicy
                             timeoutInterval:task.originalRequest.timeoutInterval];
    newRequest.HTTPMethod = task.originalRequest.HTTPMethod;
    newRequest.HTTPBody = task.originalRequest.HTTPBody;
    newRequest.allHTTPHeaderFields = task.originalRequest.allHTTPHeaderFields;
    completionHandler(newRequest);
}



@end
