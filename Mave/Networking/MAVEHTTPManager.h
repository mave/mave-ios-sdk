//
//  MAVEHTTPManager.h
//  MaveDevApp
//
//  Created by dannycosson on 10/8/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAVEUserData.h"

typedef void (^MAVEHTTPCompletionBlock)(NSError *error, NSDictionary *responseData);


@interface MAVEHTTPManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, readonly) NSString *applicationId;
@property (nonatomic, readonly) NSString *baseURL;
@property (nonatomic) NSURLSession *session;

- (MAVEHTTPManager *)initWithApplicationId:(NSString *)applicationId;

// Specific API Requests the app will make
- (void)sendInvitesWithPersons:(NSArray *)persons
                       message:(NSString *)messageText
                        userId:(NSString *)userId
               completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

- (void)trackAppOpenRequest;
- (void)identifyUserRequest:(MAVEUserData *)userData;
- (void)trackSignupRequest:(MAVEUserData *)userData;
- (void)trackInvitePageOpenRequest:(MAVEUserData *)userData;

@end