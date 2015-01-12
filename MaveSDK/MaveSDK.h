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

typedef void (^MAVEInvitePagePresentBlock)(UIViewController *inviteViewController);
typedef void (^MAVEInvitePageDismissBlock)(UIViewController *viewController, NSUInteger numberOfInvitesSent);

@interface MaveSDK : NSObject

@property (nonatomic, strong) MAVEDisplayOptions *displayOptions;
@property (nonatomic, copy) NSString *defaultSMSMessageText;
@property (nonatomic, strong) MAVEAPIInterface *APIInterface;
@property (nonatomic, strong) MAVEInvitePageChooser *invitePageChooser;
@property (nonatomic, strong) MAVERemoteObjectBuilder *remoteConfigurationBuilder;
@property (nonatomic, strong) MAVERemoteObjectBuilder *shareTokenBuilder;


@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appDeviceID;
@property (strong, nonatomic) MAVEUserData *userData;
@property (nonatomic, copy) MAVEInvitePageDismissBlock invitePageDismissalBlock;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID;
+ (instancetype)sharedInstance;

// Ability to reset the object in tests
# if DEBUG
+ (void)resetSharedInstanceForTesting;
#endif

- (void)getReferringUser:(void(^)(MAVEUserData * userData))referringUserHandler;
- (void)identifyUser:(MAVEUserData *)userData;
- (void)trackSignup;

//- (void)presentInvitePageModallyWithBlock:(MAVEInvitePagePresentBlock)presentBlock
//                             dismissBlock:(MAVEInvitePageDismissBlock)dismissBlock
//                                  context:(NSString*)presentedFrom;
//- (void)presentInvitePagePushWithBlock:(MAVEInvitePagePresentBlock)presentBlock
//                          dismissBlock:(MAVEInvitePageDismissBlock)dismissBlock
//                               context:(NSString*)presentedFrom;

- (UIViewController *)invitePageWithDefaultMessage:(NSString *)defaultMessageText
                                        setupError:(NSError *__autoreleasing *)setupError
                                    dismissalBlock:(MAVEInvitePageDismissBlock)dismissalBlock;
@end