//
//  InvitePage.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "MaveSDK.h"
#import "MaveSDK_Internal.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEConstants.h"
#import "MAVEDisplayOptions.h"
#import "MAVEHTTPManager.h"

@implementation MaveSDK {
    // Controller
    UINavigationController *invitePageNavController;
}

//
// Init and handling shared instance & needed data
//
- (instancetype)initWithAppId:(NSString *)appId {
    if (self = [self init]) {
        _appId = appId;
        _displayOptions = [[MAVEDisplayOptions alloc] initWithDefaults];
        _HTTPManager = [[MAVEHTTPManager alloc] initWithApplicationId:appId];
    }
    return self;
}

static MaveSDK *sharedInstance = nil;
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
        DebugLog(@"Error with MaveSDK shared instance setup - Application ID not set");
        errCode = MAVEValidationErrorApplicationIDNotSetCode;
    } else if (self.userData.userID == nil) {
        DebugLog(@"Error with MaveSDK shared instance setup - UserID not set");
        errCode = MAVEValidationErrorUserIDNotSetCode;
    } else if (self.userData.firstName == nil) {
        DebugLog(@"Error with MaveSDK shared instance setup - user firstName not set");
        errCode = MAVEValidationErrorUserNameNotSetCode;
    } else {
        return nil;
    }

    return [[NSError alloc] initWithDomain:MAVE_VALIDATION_ERROR_DOMAIN code:errCode userInfo:@{}];
}

//
// Funnel events that need to be called explicitly by consumer
//
- (void)trackAppOpen {
    [self.HTTPManager trackAppOpenRequest];
}

- (void)identifyUser:(MAVEUserData *)userData {
    self.userData = userData;
    NSError *validationError = [self validateSetup];
    if (validationError == nil) {
        [self.HTTPManager identifyUserRequest:userData];
    }
}

- (void)trackSignup {
    [self.HTTPManager trackSignupRequest:self.userData];
}

//
// Methods for consumer to present/manage the invite page
//
- (UIViewController *)invitePageWithDefaultMessage:(NSString *)defaultMessageText
                                        setupError:(NSError *__autoreleasing *)setupError
                                   completionBlock:(InvitePageDismissalBlock) dismissalBlock {
    self.invitePageDismissalBlock = dismissalBlock;
    UIViewController *returnViewController = nil;
    *setupError = [self validateSetup];
    if (!*setupError) {
        self.defaultSMSMessageText = defaultMessageText;
        MAVEInvitePageViewController *inviteController = [[MAVEInvitePageViewController alloc] init];
        returnViewController =
            [[UINavigationController alloc] initWithRootViewController:inviteController];
    }
    return returnViewController;
}

//- (UIViewController *)invitePageViewControllerWithDelegate:(id<MAVEInvitePageDelegate>)delegate
//                                     defaultSMSMessageText:(NSString *)defaultSMSMessageText
//                                                     error:(NSError **)error {
//    UIViewController *returnVC = nil;
//    *error = [self validateSetup];
//    if (!*error) {
//        self.defaultSMSMessageText = defaultSMSMessageText;
//        MAVEInvitePageViewController *inviteController = [[MAVEInvitePageViewController alloc] initWithDelegate:delegate];
//        returnVC = [[UINavigationController alloc] initWithRootViewController:inviteController];
//    }
//    return returnVC;
//}

@end