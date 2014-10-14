//
//  GRKNetworkController.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/8/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

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
    NSURL *url = [NSURL URLWithString: [self.baseURL stringByAppendingString:relativeURL]];
    
    NSError *jsonSerializationError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&jsonSerializationError];
    if (jsonSerializationError != nil) {
        // TODO setup errors
        NSLog(@"Oh no error serializing dict to json!");
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:methodType];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // [request setValue:self.applicationId forKey:@"X-GrowthKit-Application-ID"];
    
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
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];

    NSError *serializationError = nil;
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&serializationError];

    completionBlock(statusCode, dataDict);
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