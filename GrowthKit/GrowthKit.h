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
#import "GRKUserData.h"

@class GRKHTTPManager;

@interface GrowthKit : NSObject

@property (nonatomic, strong) GRKInvitePageViewController *viewController;
@property (nonatomic, strong) GRKDisplayOptions *displayOptions;
@property (nonatomic, strong) GRKHTTPManager *HTTPManager;

@property (nonatomic, strong) NSString *appId;
@property (strong, nonatomic) GRKUserData *userData;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID;
+ (instancetype)sharedInstance;

// Ability to reset the object in tests
# if DEBUG
+ (void)resetSharedInstanceForTesting;
#endif

- (void)identifyUser:(GRKUserData *)userData;
- (void)trackSignup;

- (UIViewController *)invitePageViewControllerWithDelegate:(id <GRKInvitePageDelegate>) delegate
                                                     error:(NSError **)error;

@end
