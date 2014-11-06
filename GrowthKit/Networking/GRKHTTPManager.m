//
//  GRKNetworkController.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/8/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "GRKConstants.h"
#import "GRKHTTPManager.h"
#import "GRKHTTPManager_Internal.h"

@implementation GRKHTTPManager

- (instancetype)initWithApplicationId:(NSString *)applicationId {
    if (self = [super init]) {
        _applicationId = applicationId;
        _baseURL = [GRKAPIBaseURL stringByAppendingString:GRKAPIVersion];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = 5.0;
        sessionConfig.timeoutIntervalForResource = 5.0;
        
        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:delegateQueue];

        DebugLog(@"Initialized GRKHTTPManager on domain %@", GRKAPIBaseURL);
    }
    return self;
}

- (void)sendIdentifiedJSONRequestWithRoute:(NSString *)relativeURL
                                methodType:(NSString *)methodType
                                    params:(NSDictionary *)params
                           completionBlock:(GRKHTTPCompletionBlock)completionBlock {
    // Parse JSON and handle errors
    NSData *jsonData;
    NSError *jsonParseError;
    if ([NSJSONSerialization isValidJSONObject:params]) {
        NSError *jsonSerializationError;
        jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&jsonSerializationError];
        if (jsonSerializationError != nil) {
            NSDictionary *userInfo = @{};
            jsonParseError = [[NSError alloc] initWithDomain:GRK_HTTP_ERROR_DOMAIN
                                                        code:GRKHTTPErrorRequestJSONCode
                                                    userInfo:userInfo];
        }
    } else {
        NSDictionary *userInfo = @{};
        jsonParseError = [[NSError alloc] initWithDomain:GRK_HTTP_ERROR_DOMAIN
                                                    code:GRKHTTPErrorRequestJSONCode
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
    
    // Send request
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:
            ^(NSData *data, NSURLResponse *response, NSError *error) {
        DebugLog(@"HTTP Request: \"%lu\" %@ %@", ((NSHTTPURLResponse *)response).statusCode, methodType, relativeURL);
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
                   completionBlock:(GRKHTTPCompletionBlock)completionBlock {
    // If Nil completion block, it was a fire and forget type request
    // so we don't need to handle the response at all
    if (completionBlock == nil) {
        return;
    }

    // Handle nil response
    if (response == nil) {
        NSError *nilResponseError = [[NSError alloc] initWithDomain:GRK_HTTP_ERROR_DOMAIN
                                                               code:GRKHTTPErrorResponseNilCode
                                                           userInfo:@{}];
        return completionBlock(nilResponseError, nil);
    }
    
    // Handle error codes
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode / 100 == 4) {
        NSError *statusCodeError = [[NSError alloc] initWithDomain:GRK_HTTP_ERROR_DOMAIN
                                                              code:GRKHTTPErrorResponse400LevelCode
                                                          userInfo:@{}];
        return completionBlock(statusCodeError, nil);
    }
    if (statusCode / 100 == 5) {
        NSError *statusCodeError = [[NSError alloc] initWithDomain:GRK_HTTP_ERROR_DOMAIN
                                                              code:GRKHTTPErrorResponse500LevelCode
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
        NSLog(@"data as string: [%@]", dataAsString);
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
                returnError = [[NSError alloc] initWithDomain:GRK_HTTP_ERROR_DOMAIN
                                                         code:GRKHTTPErrorResponseJSONCode
                                                     userInfo:@{}];
            }
        }
    } else {
        returnError = [[NSError alloc] initWithDomain:GRK_HTTP_ERROR_DOMAIN
                                                 code:GRKHTTPErrorResponseIsNotJSONCode
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
               completionBlock:(GRKHTTPCompletionBlock)completionBlock {
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

- (void)trackSignupRequest:(GRKUserData *)userData {
    NSString *signupRoute = @"/users/signup";
    NSDictionary *params = [userData toDictionaryIDOnly];
    [self sendIdentifiedJSONRequestWithRoute:signupRoute
                                  methodType:@"POST"
                                      params:params
                             completionBlock:nil];
    
}

- (void)identifyUserRequest:(GRKUserData *)userData {
    NSString *launchRoute = @"/users";
    NSDictionary *params = [userData toDictionary];
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodType:@"PUT"
                                      params:params
                             completionBlock:nil];
}

-(void)trackInvitePageOpenRequest:(GRKUserData *)userData {
    NSString *launchRoute = @"/invite_page_open";
    NSDictionary *params = [userData toDictionaryIDOnly];
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodType:@"POST"
                                      params:params
                             completionBlock:nil];
}
@end
