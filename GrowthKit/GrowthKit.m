//
//  InvitePage.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "GrowthKit.h"
#import "GrowthKit_Internal.h"
#import "GRKConstants.h"
#import "GRKInvitePageViewController.h"
#import "GRKDisplayOptions.h"
#import "GRKHTTPManager.h"

@implementation GrowthKit {
    // Controller
    UINavigationController *invitePageNavController;
}

//
// Init and handling shared instance & needed data
//
- (instancetype)initWithAppId:(NSString *)appId {
    if (self = [self init]) {
        _appId = appId;
        _displayOptions = [[GRKDisplayOptions alloc] initWithDefaults];
        _HTTPManager = [[GRKHTTPManager alloc] initWithApplicationId:appId];
    }
    return self;
}

static GrowthKit *sharedInstance = nil;
static dispatch_once_t sharedInstanceonceToken;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID {
    NSLog(@"setup shared instance");
    dispatch_once(&sharedInstanceonceToken, ^{
        NSLog(@"actually setup shared instance");
        sharedInstance = [[self alloc] initWithAppId:applicationID];
        [sharedInstance trackAppOpen];
    });
}

# if DEBUG
+ (void)resetSharedInstanceForTesting {
    sharedInstanceonceToken = 0;
}
#endif

+ (instancetype)sharedInstance {
    if (sharedInstance == nil) {
        NSLog(@"Error: didn't setup shared instance with app id");
    }
    return sharedInstance;
}

- (NSError *)validateSetup {
    NSInteger errCode = 0;
    if (self.appId == nil) {
        DebugLog(@"Error with GrowthKit shared instance setup - Application ID not set");
        errCode = GRKValidationErrorApplicationIDNotSetCode;
    } else if (self.userData.userID == nil) {
        DebugLog(@"Error with GrowthKit shared instance setup - UserID not set");
        errCode = GRKValidationErrorUserIDNotSetCode;
    } else if (self.userData.firstName == nil) {
        DebugLog(@"Error with GrowthKit shared instance setup - user firstName not set");
        errCode = GRKValidationErrorUserNameNotSetCode;
    } else {
        return nil;
    }

    return [[NSError alloc] initWithDomain:GRK_VALIDATION_ERROR_DOMAIN code:errCode userInfo:@{}];
}

//
// Funnel events that need to be called explicitly by consumer
//
- (void)trackAppOpen {
    [self.HTTPManager trackAppOpenRequest];
}

- (void)identifyUser:(GRKUserData *)userData {
    self.userData = userData;
    [self.HTTPManager identifyUserRequest:userData];
}

- (void)trackSignup {
    [self.HTTPManager trackSignupRequest:self.userData];
}

//
// Methods for consumer to present/manage the invite page
//
- (UIViewController *)invitePageViewControllerWithDelegate:(id<GRKInvitePageDelegate>)delegate
                                           validationError:(NSError **)error{
    UIViewController *returnVC = nil;
    *error = [self validateSetup];
    if (!*error) {
        GRKInvitePageViewController *inviteController = [[GRKInvitePageViewController alloc] initWithDelegate:delegate];
        returnVC = [[UINavigationController alloc] initWithRootViewController:inviteController];
    }
    return returnVC;
}

@end