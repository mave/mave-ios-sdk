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
    NSError *returnError;
    NSDictionary *returnDict;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
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

    completionBlock(returnError, returnDict);
}

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

@end