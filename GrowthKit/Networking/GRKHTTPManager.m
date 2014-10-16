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
        _baseURL = @"http://devaccounts.growthkit.io/v1.0";
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
         configuration.HTTPAdditionalHeaders = [[self class] defaultHeaders];
        
        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:delegateQueue];
    }
    return self;
}

+ (NSDictionary *)defaultHeaders {
    return @{@"Accept": @"application/json",
           };
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
            jsonParseError = [[NSError alloc] initWithDomain:GRK_ERROR_DOMAIN
                                                        code:GRKHTTPErrorRequestJSONCode
                                                    userInfo:userInfo];
        }
    } else {
        NSDictionary *userInfo = @{};
        jsonParseError = [[NSError alloc] initWithDomain:GRK_ERROR_DOMAIN
                                                    code:GRKHTTPErrorRequestJSONCode
                                                userInfo:userInfo];
    }
    if (jsonParseError != nil) {
        return completionBlock(jsonParseError, nil);
    }
    
    // Build request
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString:relativeURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:methodType];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // [request setValue:self.applicationId forKey:@"X-GrowthKit-Application-ID"];
    
    // Send request
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:
            ^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Headers sent: %@", request.allHTTPHeaderFields);
        
        [[self class] handleJSONResponseWithData:data
                                        response:response
                                           error:error
                                 completionBlock:completionBlock];
    }];
    [task resume];
}

+ (void)handleJSONResponseWithData:(NSData *)data
                          response:(NSURLResponse *)response
                             error:(NSError *)error
                   completionBlock:(GRKHTTPCompletionBlock)completionBlock {
    // If Nil completion block, it was a "fire and forget" type request
    // so we don't need to handle the response at all
    if (completionBlock == nil) {
        return;
    }

    // Handle nil response
    if (response == nil) {
        NSError *nilResponseError = [[NSError alloc] initWithDomain:GRK_ERROR_DOMAIN
                                                               code:GRKHTTPErrorResponseNilCode
                                                           userInfo:@{}];
        return completionBlock(nilResponseError, nil);
    }
    
    // Handle error codes
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode / 100 == 4) {
        NSError *statusCodeError = [[NSError alloc] initWithDomain:GRK_ERROR_DOMAIN
                                                              code:GRKHTTPErrorResponse400LevelCode
                                                          userInfo:@{}];
        return completionBlock(statusCodeError, nil);
    }
    if (statusCode / 100 == 5) {
        NSError *statusCodeError = [[NSError alloc] initWithDomain:GRK_ERROR_DOMAIN
                                                              code:GRKHTTPErrorResponse500LevelCode
                                                          userInfo:@{}];
        return completionBlock(statusCodeError, nil);
        
    }
    
    // Handle formatting & displaying response
    NSError *returnError;
    NSDictionary *returnDict;
    NSString *contentType = [httpResponse.allHeaderFields valueForKey:@"Content-Type"];
    if ([contentType isEqualToString: @"application/json"]) {
        NSError *serializationError;
        returnDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&serializationError];
        if (serializationError != nil) {
            returnError = [[NSError alloc] initWithDomain:GRK_ERROR_DOMAIN
                                                     code:GRKHTTPErrorResponseJSONCode
                                                 userInfo:@{}];
        }
    } else {
        returnError = [[NSError alloc] initWithDomain:GRK_ERROR_DOMAIN
                                                 code:GRKHTTPErrorResponseIsNotJSONCode
                                             userInfo:@{}];
    }
    return completionBlock(returnError, returnDict);
}

// Individual wrappers for API requests
- (void)sendInvitesWithPersons:(NSArray *)persons
                       message:(NSString *)messageText
               completionBlock:(GRKHTTPCompletionBlock)completionBlock {
    NSString *invitesRoute = @"/invites";
    NSDictionary *params = @{@"recipients": persons,
                             @"sms_copy": messageText,
                           };
    [self sendIdentifiedJSONRequestWithRoute:invitesRoute
                       methodType:@"POST"
                           params:params
                  completionBlock:completionBlock];
}

- (void)sendApplicationLaunchNotification {
    NSString *launchRoute = @"/launch";
    NSDictionary *params = @{};
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodType:@"POST"
                                      params:params
                             completionBlock:nil];
}

- (void)sendUserSignupNotificationWithUserID:(NSString *)userId
                                       email:(NSString *)email
                                       phone:(NSString *)phone {
    NSString *launchRoute = @"/users";
    NSDictionary *params = @{@"user_id": userId,
                             @"email": email,
                             @"phone": phone,
                           };
    [self sendIdentifiedJSONRequestWithRoute:launchRoute
                                  methodType:@"POST"
                                      params:params
                             completionBlock:nil];
}

@end