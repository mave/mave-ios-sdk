//
//  GRKHTTPManager.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/8/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GRKHTTPCompletionBlock)(NSError *error, NSDictionary *responseData);


@interface GRKHTTPManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, readonly) NSString *applicationId;
@property (nonatomic, readonly) NSString *baseURL;
@property (nonatomic) NSURLSession *session;

- (GRKHTTPManager *)initWithApplicationId:(NSString *)applicationId;

// Specific API Requests the app will make
- (void)sendInvitesWithPersons:(NSArray *)persons
                       message:(NSString *)messageText
               completionBlock:(GRKHTTPCompletionBlock)completionBlock;

- (void)sendApplicationLaunchNotification;
- (void)sendUserSignupNotificationWithUserID:(NSString *)userId
                                       email:(NSString *)email
                                       phone:(NSString *)phone;
- (void)sendInvitePageOpen:(NSString *)userID;

@end