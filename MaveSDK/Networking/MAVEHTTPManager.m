//
//  MAVENetworkController.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/8/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "MAVEConstants.h"
#import "MAVEHTTPManager.h"
#import "MAVEHTTPManager_Internal.h"

@implementation MAVEHTTPManager

- (instancetype)init {
    if (self = [super init]) {
        // Set hard-coded constants
        self.baseURL = [MAVEAPIBaseURL stringByAppendingString:MAVEAPIVersion];
    }
    return self;
}

- (instancetype)initWithApplicationId:(NSString *)applicationId {
    if (self = [self init]) {
        _applicationId = applicationId;
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = 5.0;
        sessionConfig.timeoutIntervalForResource = 5.0;
        
        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:delegateQueue];

        DebugLog(@"Initialized MAVEHTTPManager on domain %@ with applicationID %@", MAVEAPIBaseURL, _applicationId);
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler {
    // Always redirect with the same method, body, headers as original request
    //
    // NB: Default behavior in all HTTP clients including this one is
    // for same method to be used unless it's POST in which case it gets
    // changed to GET, and for request body to be dropped
    NSMutableURLRequest *newRequest =
        [[NSMutableURLRequest alloc] initWithURL:request.URL
                                     cachePolicy:request.cachePolicy
                                 timeoutInterval:request.timeoutInterval];
    newRequest.HTTPMethod = task.originalRequest.HTTPMethod;
    newRequest.HTTPBody = task.originalRequest.HTTPBody;
    newRequest.allHTTPHeaderFields = task.originalRequest.allHTTPHeaderFields;
    completionHandler(newRequest);
}

- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                methodType:(NSString *)methodType
                                    params:(NSDictionary *)params
                           completionBlock:(MAVEHTTPCompletionBlock)completionBlock {
    // Parse JSON and handle errors
    NSData *jsonData;
    NSError *jsonParseError;
    if ([NSJSONSerialization isValidJSONObject:params]) {
        NSError *jsonSerializationError;
        jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&jsonSerializationError];
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
        if (completionBlock != nil) {
            completionBlock(jsonParseError, nil);
        }
        return;
    }
    
    // Build request
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString:relativeURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:methodType];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:self.applicationId forHTTPHeaderField:@"X-Application-ID"];
    NSString *userAgent =
        [[self class] userAgentWithUIDevice:[UIDevice currentDevice]];
    NSString *screenSize =
        [[self class] formattedScreenSize:[UIScreen mainScreen].bounds.size];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue: screenSize forHTTPHeaderField:@"X-Device-Screen-Dimensions"];

    // Send request
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:
            ^(NSData *data, NSURLResponse *response, NSError *error) {
        DebugLog(@"HTTP Request: \"%lu\" %@ %@", (long)((NSHTTPURLResponse *)response).statusCode, methodType, relativeURL);
        [[self class] handleJSONResponseWithData:data
                                        response:response
                                           error:error
                                 completionBlock:completionBlock];
    }];
    [task resume];
    return;
}

+ (void)handleJSONResponseWithData:(NSData *)data
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
    if (statusCode / 100 == 4) {
        NSError *statusCodeError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN
                                                              code:MAVEHTTPErrorResponse400LevelCode
                                                          userInfo:@{}];
        return completionBlock(statusCodeError, nil);
    }
    if (statusCode / 100 == 5) {
        NSError *statusCodeError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN
                                                              code:MAVEHTTPErrorResponse500LevelCode
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
                DebugLog(@"Bad JSON error: %@", data);
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

//
// Wrappers for the various API requests
//
- (void)sendInvitesWithPersons:(NSArray *)persons
                       message:(NSString *)messageText
                        userId:(NSString *)userId
               completionBlock:(MAVEHTTPCompletionBlock)completionBlock {
    NSString *invitesRoute = @"/invites/sms";
    NSDictionary *params = @{@"recipients": persons,
                             @"sms_copy": messageText,
                             @"sender_user_id": userId
                           };
    [self sendIdentifiedJSONRequestWithRoute:invitesRoute
                       methodType:@"POST"
                           params:params
                  completionBlock:completionBlock];
}

- (void)trackAppOpenRequest {
    NSString *launchRoute = @"/launch";
    NSDictionary *params = @{};
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodType:@"POST"
                                      params:params
                             completionBlock:nil];
}

- (void)trackSignupRequest:(MAVEUserData *)userData {
    NSString *signupRoute = @"/users/signup";
    NSDictionary *params = [userData toDictionaryIDOnly];
    [self sendIdentifiedJSONRequestWithRoute:signupRoute
                                  methodType:@"POST"
                                      params:params
                             completionBlock:nil];
    
}

- (void)identifyUserRequest:(MAVEUserData *)userData {
    NSString *launchRoute = @"/users";
    NSDictionary *params = [userData toDictionary];
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodType:@"PUT"
                                      params:params
                             completionBlock:nil];
}

- (void)trackInvitePageOpenRequest:(MAVEUserData *)userData {
    NSString *launchRoute = @"/invite_page_open";
    NSDictionary *params = [userData toDictionaryIDOnly];
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodType:@"POST"
                                      params:params
                             completionBlock:nil];
}

// Utils
+ (NSString *)formattedScreenSize:(CGSize)size {
    long w = (long)round(size.width);
    long h = (long)round(size.height);
    if (w > h) {
        long tmp = w;
        w = h;
        h = tmp;
    }
    return [NSString stringWithFormat:@"%ldx%ld", w, h];
}

+ (NSString *)userAgentWithUIDevice:(UIDevice *)device {
    NSString *iosVersionStr =
        [device.systemVersion stringByReplacingOccurrencesOfString:@"."
                                                        withString:@"_"];
    return [NSString stringWithFormat:@"(iPhone; CPU iPhone OS %@ like Mac OS X)",
            iosVersionStr];
}

@end
