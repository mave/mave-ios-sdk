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
#import "GRKHTTPManager.h"

@interface GrowthKit : NSObject

@property (nonatomic, readonly) GRKInvitePageViewController *viewController;
@property (nonatomic, readonly) GRKDisplayOptions *displayOptions;
@property (nonatomic) GRKHTTPManager *HTTPManager;

@property (nonatomic, readonly) NSString *appId;
@property (nonatomic, readonly) NSString *currentUserId;
@property (nonatomic, readonly) NSString *currentUserFirstName;
@property (nonatomic, readonly) NSString *currentUserLastName;

+ (void)setupSharedInstanceWithAppId:(NSString *)appId;
+ (GrowthKit *)sharedInstance;

- (void)setUserData:(NSString *)userId firstName:(NSString *)firstName lastName:(NSString *)lastName;

- (void)presentInvitePage:(UIViewController *)sourceController;

@end


@protocol GRKInvitePageDelegate <NSObject>

@optional
- (void)invitesFailedToSend:(NSError *)error;
- (void)invitesSent:(NSUInteger *)number;
- (void)invitesNotSent;

@end