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
#import "MAVERemoteConfiguration.h"
#import "MAVEShareToken.h"
#import "MAVECustomSharePageViewController.h"

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

        _invitePageChooser = [[MAVEInvitePageChooser alloc] init];
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

        sharedInstance.remoteConfigurationBuilder = [MAVERemoteConfiguration remoteBuilder];
        sharedInstance.shareTokenBuilder = [MAVEShareToken remoteBuilder];
    });
}

// ability to reset singleton during tests
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

- (BOOL)isSetupOK {
    NSString *errorFormat = @"Issue with MaveSDK setup - %@.";
    BOOL ok = YES;
    if (!self.appId) {
        ErrorLog(errorFormat, @"applicationID is nil");
        ok = NO;
    }
    if (!self.invitePageDismissalBlock) {
        ErrorLog(errorFormat, @"invite page dismiss block was nil");
        ok = NO;
    }
    return ok;
}

- (MAVERemoteConfiguration *)remoteConfiguration {
    id obj = [self.remoteConfigurationBuilder createObjectSynchronousWithTimeout:0];
    return (MAVERemoteConfiguration *)obj;
}

- (NSString *)defaultSMSMessageText {
    if (_defaultSMSMessageText) {
        return _defaultSMSMessageText;
    } else {
        return self.remoteConfiguration.contactsInvitePage.smsCopy;
    }
}

- (NSString *)inviteExplanationCopy {
    if (self.displayOptions.inviteExplanationCopy) {
        return self.displayOptions.inviteExplanationCopy;
    } else {
        return self.remoteConfiguration.contactsInvitePage.explanationCopy;
    }
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

- (void)identifyAnonymousUser {
    MAVEUserData *user = [[MAVEUserData alloc] initAutomaticallyFromDeviceName];
    if (user) {
        [self identifyUser:user];
    }
}

- (void)trackSignup {
    [self.APIInterface trackSignup];
}

//
// Methods for consumer to present/manage the invite page
//

- (void)presentInvitePageModallyWithBlock:(MAVEInvitePagePresentBlock)presentBlock
                             dismissBlock:(MAVEInvitePageDismissBlock)dismissBlock
                            inviteContext:(NSString *)inviteContext {
    self.invitePageDismissalBlock = dismissBlock;
    if (![self isSetupOK]) {
        ErrorLog(@"Not displaying Mave invite page because parameters not all set, see other log errors");
        return;
    }
    UIViewController *vc = [self.invitePageChooser chooseAndCreateInvitePageViewController];
    UIViewController *navigationVC = [self.invitePageChooser embedInNavigationController:vc];
    self.inviteContext = inviteContext;
    presentBlock(navigationVC);
}

// Deprecated
- (UIViewController *)invitePageWithDefaultMessage:(NSString *)defaultMessageText
                                        setupError:(NSError *__autoreleasing *)setupError
                                    dismissalBlock:(MAVEInvitePageDismissBlock) dismissalBlock {
    self.invitePageDismissalBlock = dismissalBlock;
    UIViewController *returnViewController = nil;
    if ([self isSetupOK]) {
        self.defaultSMSMessageText = defaultMessageText;
        UIViewController *viewController = [self.invitePageChooser chooseAndCreateInvitePageViewController];
        returnViewController = [self.invitePageChooser embedInNavigationController:viewController];
    } else {
        *setupError = [[NSError alloc]initWithDomain:MAVE_VALIDATION_ERROR_DOMAIN code:5 userInfo:@{@"message": @"MaveSDK not setup properly, check the logs"}];

    }
    return returnViewController;
}

@end