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
    [request setValue:self.applicationId forKey:@"X-GrowthKit-Application-ID"];
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:
            ^(NSData *data, NSURLResponse *response, NSError *error) {
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
}





//- (void)sendInvites:(id)sender {
//    NSString *appToken = @"e2788bf35c8d1fea98b1bd0d25ec11ec";
//    
//    // NSLog(@"Would send '%@' to: %@", self.messageTextField.text, _selectedPhones);
//    NSString *baseURL = @"http://devaccounts.growthkit.io/v1.0";
//    NSString *urlString = [baseURL stringByAppendingString:@"/invites"];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
//    [request setHTTPMethod:@"POST"];
//    
//    NSArray *phonesToInvite = [self.selectedPhones allObjects];
//    
//    NSDictionary *params = @{
//        @"app_token": appToken,
//        @"recipients": phonesToInvite,
//        @"sms_copy": self.messageTextField.text,
//    };
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
//    if (error != nil) {
//        NSLog(@"Oh no error serializing dict to json!");
//    }
//    NSLog(@"Logged dict to json: %@", params);
//    [request  setHTTPBody:jsonData];
//    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setResponseSerializer:[AFHTTPResponseSerializer serializer]];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success!");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Failure: %@", [error localizedDescription]);
//    }];
//    [operation start];
//}

@end
