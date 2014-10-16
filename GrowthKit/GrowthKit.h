//
//  InvitePage.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRKInvitePageViewController.h"
#import "GRKDisplayOptions.h"

@class GRKHTTPManager;

@interface GrowthKit : NSObject

@property (nonatomic, readonly) GRKInvitePageViewController *viewController;
@property (nonatomic, readonly) GRKDisplayOptions *displayOptions;
@property (nonatomic, strong) GRKHTTPManager *HTTPManager;

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *currentUserId;
@property (nonatomic, strong) NSString *currentUserFirstName;
@property (nonatomic, strong) NSString *currentUserLastName;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID;
+ (GrowthKit *)sharedInstance;

- (void)setUserData:(NSString *)userId
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName;

- (void)registerNewUserSignup:(NSString *)userId
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        email:(NSString *)email
                        phone:(NSString *)phone;

- (void)presentInvitePage:(UIViewController *)sourceController;

@end


@protocol GRKInvitePageDelegate <NSObject>

@optional
- (void)invitesFailedToSend:(NSError *)error;
- (void)invitesSent:(NSUInteger *)number;
- (void)invitesNotSent;

@end