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

@class MAVEHTTPManager;

@interface MaveSDK : NSObject

@property (nonatomic, strong) MAVEInvitePageViewController *viewController;
@property (nonatomic, strong) MAVEDisplayOptions *displayOptions;
@property (nonatomic, strong) NSString *defaultSMSMessageText;
@property (nonatomic, strong) MAVEHTTPManager *HTTPManager;

@property (nonatomic, strong) NSString *appId;
@property (strong, nonatomic) MAVEUserData *userData;
@property (nonatomic, copy) InvitePageDismissalBlock invitePageDismissalBlock;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID;
+ (instancetype)sharedInstance;

// Ability to reset the object in tests
# if DEBUG
+ (void)resetSharedInstanceForTesting;
#endif

- (void)identifyUser:(MAVEUserData *)userData;
- (void)trackSignup;

- (UIViewController *)invitePageWithDefaultMessage:(NSString *)defaultMessageText
                                        setupError:(NSError *__autoreleasing *)setupError
                                    dismissalBlock:(InvitePageDismissalBlock)dismissalBlock;
@end