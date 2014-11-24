//
//  MAVEHTTPManager.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/8/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MAVEUserData.h"

typedef void (^MAVEHTTPCompletionBlock)(NSError *error, NSDictionary *responseData);


@interface MAVEHTTPManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSString *applicationID;
@property (strong, nonatomic) NSString *applicationDeviceID;
@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSURLSession *session;

// UserAgent & screenSize are for fingerprinting
+ (NSString *)userAgentWithUIDevice:(UIDevice *)device;
+ (NSString *)formattedScreenSize:(CGSize)size;

- (MAVEHTTPManager *)initWithApplicationID:(NSString *)applicationID
                       applicationDeviceID:(NSString *)applicationDeviceID;

// Specific API Requests the app will make
- (void)sendInvitesWithPersons:(NSArray *)persons
                       message:(NSString *)messageText
                        userId:(NSString *)userId
      inviteLinkDestinationURL:(NSString *)inviteLinkDestinationURL
               completionBlock:(MAVEHTTPCompletionBlock)completionBlock;

- (void)trackAppOpenRequest;
- (void)identifyUserRequest:(MAVEUserData *)userData;
- (void)trackSignupRequest:(MAVEUserData *)userData;
- (void)trackInvitePageOpenRequest:(MAVEUserData *)userData;

@end