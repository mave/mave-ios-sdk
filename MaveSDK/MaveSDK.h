//
//  InvitePage.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEInvitePageViewController.h"
#import "MAVEDisplayOptions.h"
#import "MAVEUserData.h"
#import "MAVEInvitePageChooser.h"
#import "MAVEAPIInterface.h"
#import "MAVERemoteObjectBuilder.h"
#import "MAVECustomSharePageViewController.h"

@interface MaveSDK : NSObject

@property (nonatomic, strong) MAVEDisplayOptions *displayOptions;
@property (nonatomic, copy) NSString *defaultSMSMessageText;
@property (nonatomic, strong) MAVEAPIInterface *APIInterface;
@property (nonatomic, strong) MAVEInvitePageChooser *invitePageChooser;
@property (nonatomic, strong) MAVERemoteObjectBuilder *remoteConfigurationBuilder;
@property (nonatomic, strong) MAVERemoteObjectBuilder *shareTokenBuilder;


@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appDeviceID;
@property (nonatomic, copy) NSString *inviteContext;
@property (nonatomic, strong) MAVEUserData *userData;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID;
+ (instancetype)sharedInstance;

// Internal, method to access the remote configuration
- (MAVERemoteConfiguration *)remoteConfiguration;

- (BOOL)isSetupOK;

- (void)getReferringUser:(void(^)(MAVEUserData * userData))referringUserHandler;
// Use this to identify your logged-in users to us
- (void)identifyUser:(MAVEUserData *)userData;
// Use anonymous users if you don't have user accounts. Mave will generate
// a user id to match this device in the future and try to get the user's name
// from the device info. If we can't get the user's name
- (void)identifyAnonymousUser;

- (void)trackSignup;

// Present the view controller modally (or in a drawer, etc.)
//
// @presentBlock - block for you to present the Mave invite view controller from your app
// @dismissBlock - block to transition back to your app after user sends invites or cancels.
//                 It gets a "number of invites sent" parameter if you need to tell whether
//                   the user sent any invites/shared or not.
// @inviteContext - a string to identify where the invite page was presented from. If you are
//                  displaying the invite page from multiple places in your app (e.g. from the
//                  menu and in the signup flow) this is important for tracking because you
//                  typically expect the page to perform differently depending on where it's
//                  presented from.
- (void)presentInvitePageModallyWithBlock:(MAVEInvitePagePresentBlock)presentBlock
                             dismissBlock:(MAVEInvitePageDismissBlock)dismissBlock
                            inviteContext:(NSString*)inviteContext;

// Present the invite page by pushing onto an existing navigation controller stack
// Otherwise it's the same as previous method.
- (void)presentInvitePagePushWithBlock:(MAVEInvitePagePresentBlock)presentBlock
                             forwardBlock:(MAVEInvitePageDismissBlock)forwardBlock
                             backBlock:(MAVEInvitePageDismissBlock)backBlock
                         inviteContext:(NSString *)inviteContext;
@end