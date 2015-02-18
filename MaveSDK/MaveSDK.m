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

    // Properties with overwritten getters & setters
    MAVEUserData *_userData;
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
        _addressBookSyncManager = [[MAVEABSyncManager alloc] init];
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

#ifndef UNIT_TESTING
        // sync contacts, but wait a few seconds so it doesn't compete with fetching our
        // share token or remote configuration.
        // Don't run this in unit tests because it interferes with the other tests.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [sharedInstance.addressBookSyncManager syncContactsInBackgroundIfAlreadyHavePermission];
        });
#endif
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
        MAVEErrorLog(@"You did not set up shared instance with app id");
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
    MAVEDebugLog(@"Error with MaveSDK sharedInstance user info setup - %@", humanError);
    return [[NSError alloc] initWithDomain:MAVE_VALIDATION_ERROR_DOMAIN
                                      code:errCode
                                  userInfo:@{@"message": humanError}];
}

- (BOOL)isSetupOK {
    NSString *errorFormat = @"Issue with MaveSDK setup - %@.";
    BOOL ok = YES;
    if (!self.appId) {
        MAVEErrorLog(errorFormat, @"applicationID is nil");
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
        return self.remoteConfiguration.serverSMS.text;
    }
}

- (NSString *)inviteExplanationCopy {
    NSString *serverCopy = self.remoteConfiguration.contactsInvitePage.explanationCopy;
    if (self.displayOptions.inviteExplanationCopy) {
        return self.displayOptions.inviteExplanationCopy;
    } else {
        return serverCopy;
    }
}

// Persist userData to disk, if app doesn't set it we can use the on-disk value
// that it set last time (if any)
- (MAVEUserData *)userData {
    if (!_userData) {
        @try {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:MAVEUserDefaultsKeyUserData];
            NSDictionary *userDataAttrs = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (userDataAttrs && [userDataAttrs count] > 0) {
                _userData = [[MAVEUserData alloc] initWithDictionary:userDataAttrs];
            }
        }
        @catch (NSException *exception) {
            _userData = nil;
        }
    }
    return _userData;
}

- (void)setUserData:(MAVEUserData *)userData {
    _userData = userData;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[userData toDictionary]];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:MAVEUserDefaultsKeyUserData];
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
    if (![self isSetupOK]) {
        MAVEErrorLog(@"Not displaying Mave invite page because parameters not all set, see other log errors");
        return;
    }
    self.invitePageChooser = [[MAVEInvitePageChooser alloc]
                              initForModalPresentWithCancelBlock:dismissBlock];
    [self.invitePageChooser chooseAndCreateInvitePageViewController];
    [self.invitePageChooser setupNavigationBarForActiveViewController];
    self.inviteContext = inviteContext;
    presentBlock(self.invitePageChooser.activeViewController.navigationController);
}

- (void)presentInvitePagePushWithBlock:(MAVEInvitePagePresentBlock)presentBlock
                          forwardBlock:(MAVEInvitePageDismissBlock)forwardBlock
                            backBlock:(MAVEInvitePageDismissBlock)backBlock
                         inviteContext:(NSString *)inviteContext {
    if (![self isSetupOK]) {
        MAVEErrorLog(@"Not displaying Mave invite page because parameters not all set, see other log errors");
        return;
    }
    self.invitePageChooser = [[MAVEInvitePageChooser alloc]
                              initForPushPresentWithForwardBlock:forwardBlock
                              backBlock:backBlock];
    [self.invitePageChooser chooseAndCreateInvitePageViewController];
    [self.invitePageChooser setupNavigationBarForActiveViewController];
    self.inviteContext = inviteContext;
    presentBlock(self.invitePageChooser.activeViewController);
}

@end