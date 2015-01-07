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
#import "MAVEIDUtils.h"
#import "MAVEDisplayOptions.h"
#import "MAVERemoteConfigurator.h"
#import "MAVERemoteConfiguration.h"

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
        _appDeviceID = [MAVEIDUtils loadOrCreateNewAppDeviceID];
        _displayOptions = [[MAVEDisplayOptions alloc] initWithDefaults];
        _APIInterface = [[MAVEAPIInterface alloc] init];
    }
    return self;
}

static MaveSDK *sharedInstance = nil;
static dispatch_once_t sharedInstanceonceToken;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID {
    dispatch_once(&sharedInstanceonceToken, ^{
        sharedInstance = [[self alloc] initWithAppId:applicationID];
        [sharedInstance trackAppOpen];

        sharedInstance.remoteConfigurationBuilder = [MAVERemoteConfiguration remoteConfigurationBuilder];
    });
}

# if DEBUG
+ (void)resetSharedInstanceForTesting {
    sharedInstanceonceToken = 0;
}
#endif

+ (instancetype)sharedInstance {
    if (sharedInstance == nil) {
        DebugLog(@"Error: didn't setup shared instance with app id");
    }
    return sharedInstance;
}

- (NSError *)validateUserSetup {
    NSInteger errCode = 0;
    NSString *humanError = @"";
    if (self.appId == nil) {
        humanError = @"applicationID is nil";
        errCode = MAVEValidationErrorApplicationIDNotSetCode;
    } else if (self.userData == nil) {
        humanError = @"identifyUser not called";
        errCode = MAVEValidationErrorUserIdentifyNeverCalledCode;
    } else if (self.userData.userID == nil) {
        humanError = @"userID set to nil";
        errCode = MAVEValidationErrorUserIDNotSetCode;
    } else if (self.userData.firstName == nil) {
        humanError = @"user firstName set to nil";
        errCode = MAVEValidationErrorUserNameNotSetCode;
    } else {
        return nil;
    }
    DebugLog(@"Error with MaveSDK sharedInstance user info setup - %@", humanError);
    return [[NSError alloc] initWithDomain:MAVE_VALIDATION_ERROR_DOMAIN
                                      code:errCode
                                  userInfo:@{@"message": humanError}];
}

- (NSError *)validateSetup {
    NSError *error = [self validateUserSetup];
    if (error) {
        return error;
    }

    // Validate non user info fields
    NSInteger errCode = 0;
    NSString *humanError = @"";
    if (self.invitePageDismissalBlock == nil) {
        humanError = @"invite page dismissalBlock was nil";
        errCode = MAVEValidationErrorDismissalBlockNotSetCode;
    } else {
        return nil;
    }
    DebugLog(@"Error with MaveSDK sharedInstance setup - %@", humanError);
    return [[NSError alloc] initWithDomain:MAVE_VALIDATION_ERROR_DOMAIN
                                      code:errCode
                                  userInfo:@{@"message": humanError}];
}

//
// Methods to get data from our sdk
//
- (void)getReferringUser:(void (^)(MAVEUserData *))referringUserHandler {
    [self.APIInterface getReferringUser:referringUserHandler];
}

//
// Funnel events that need to be called explicitly by consumer
//
- (void)trackAppOpen {
    [self.APIInterface trackAppOpen];
}

- (void)identifyUser:(MAVEUserData *)userData {
    self.userData = userData;
    NSError *validationError = [self validateUserSetup];
    if (validationError == nil) {
        [self.APIInterface identifyUser];
    }
}

- (void)trackSignup {
    [self.APIInterface trackSignup];
}

//
// Methods for consumer to present/manage the invite page
//
- (UIViewController *)invitePageWithDefaultMessage:(NSString *)defaultMessageText
                                        setupError:(NSError *__autoreleasing *)setupError
                                    dismissalBlock:(InvitePageDismissalBlock) dismissalBlock {
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

@end