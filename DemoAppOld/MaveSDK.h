//
//  InvitePage.h
//  MaveDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEInvitePageViewController.h"
#import "MAVEDisplayOptions.h"

@interface Mave : NSObject

@property (nonatomic, readonly) MAVEInvitePageViewController *viewController;
@property (nonatomic, readonly) MAVEDisplayOptions *displayOptions;

@property (nonatomic, readonly) NSString *appId;
@property (nonatomic, readonly) NSString *currentUserId;
@property (nonatomic, readonly) NSString *currentUserFirstName;
@property (nonatomic, readonly) NSString *currentUserLastName;

+ (void)setupSharedInstanceWithAppId:(NSString *)appId;
+ (Mave *)sharedInstance;

- (void)setUserData:(NSString *)userId firstName:(NSString *)firstName lastName:(NSString *)lastName;

- (void)presentInvitePage:(UIViewController *)sourceController;

@end


@protocol MAVEInvitePageDelegate <NSObject>

@optional
- (void)invitesFailedToSend:(NSError *)error;
- (void)invitesSent:(NSUInteger *)number;
- (void)invitesNotSent;

@end