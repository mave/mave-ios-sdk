//
//  MAVEInvitePageChooser.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import "MaveSDK.h"
#import "MaveSDK_Internal.h"
#import "MAVEInvitePageChooser.h"
#import "MAVEWrapperNavigationController.h"
#import "MAVEConstants.h"
#import "MAVEABUtils.h"
#import "MAVERemoteConfiguration.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEDisplayOptions.h"

NSString * const MAVEInvitePageTypeContactList = @"contact_list";
NSString * const MAVEInvitePageTypeContactListV2 = @"contact_list_v2";
NSString * const MAVEInvitePageTypeCustomShare = @"mave_custom_share";
NSString * const MAVEInvitePageTypeNativeShareSheet = @"native_share_sheet";

NSString * const MAVEInvitePagePresentFormatModal = @"modal";
NSString * const MAVEInvitePagePresentFormatPush = @"push";

@implementation MAVEInvitePageChooser {
    // This is just the view controller's navigation controller, but that's a weak reference
    // so sometimes we'll want to store it here
    __strong UINavigationController *_activeNavigationController;
}

- (instancetype)initForModalPresentWithCancelBlock:(MAVEInvitePageDismissBlock)cancelBlock {
    if (self = [super init]) {
        self.navigationPresentedFormat = MAVEInvitePagePresentFormatModal;
        self.navigationCancelBlock = cancelBlock;
    }
    return self;
}

- (instancetype)initForPushPresentWithForwardBlock:(MAVEInvitePageDismissBlock)forwardBlock
                                      backBlock:(MAVEInvitePageDismissBlock)backBlock {
    if (self = [super init]) {
        self.navigationPresentedFormat = MAVEInvitePagePresentFormatPush;
        self.navigationForwardBlock = forwardBlock;
        self.navigationBackBlock = backBlock;
    }
    return self;
}


- (UIViewController *)chooseAndCreateInvitePageViewController {
    // Based on the primary and fallback page configuration options,
    // display the appropriate invite page.
    MAVERemoteConfigurationInvitePageChoice *invitePageConfig = [MaveSDK sharedInstance].remoteConfiguration.invitePageChoice;
    UIViewController *vc = [self createViewControllerOfType:invitePageConfig.primaryPageType];
    if (!vc) {
        vc = [self createViewControllerOfType:invitePageConfig.fallbackPageType];
    }
    // if fallback failed, try the share page as a second fallback since it has no restrictions
    // on when it can be displayed
    if (!vc) {
        MAVEErrorLog(@"Error, got nil view controller from fallback page type, trying share page");
        vc = [[MAVECustomSharePageViewController alloc] init];
    }
    self.activeViewController = vc;
    return vc;
}

- (UIViewController *)createViewControllerOfType:(MAVEInvitePageType)invitePageType {
    switch (invitePageType) {
        case MAVEInvitePageTypeContactsInvitePage:
            return [self createContactsInvitePageV3IfAllowed];
        case MAVEInvitePageTypeContactsInvitePageV2:
            return [self createContactsInvitePageV2IfAllowed];
        case MAVEInvitePageTypeSharePage:
            return [[MAVECustomSharePageViewController alloc] init];
        case MAVEInvitePageTypeClientSMS:
            return [self createClientSMSInvitePage];
        case MAVEInvitePageTypeNone:
            return nil;
    }
}

- (MAVEInvitePageViewController *)createContactsInvitePageIfAllowed {
    if ([self isAnyServerSideContactsInvitePageAllowed]) {
        return [[MAVEInvitePageViewController alloc] init];
    } else {
        return nil;
    }
}

- (MAVEContactsInvitePageV2ViewController *)createContactsInvitePageV2IfAllowed {
    if ([self isAnyServerSideContactsInvitePageAllowed]) {
        return [[MAVEContactsInvitePageV2ViewController alloc] init];
    } else {
        return nil;
    }
}

- (MAVEContactsInvitePageV3ViewController *)createContactsInvitePageV3IfAllowed {
    if ([self isAnyServerSideContactsInvitePageAllowed]) {
        return [[MAVEContactsInvitePageV3ViewController alloc] init];
    } else {
        return nil;
    }
}


- (BOOL)isAnyServerSideContactsInvitePageAllowed {
    // Once we fully support client-side invite send method, incorporate that option
    // into the logic:
    //  MAVESMSInviteSendMethod smsInviteSendMethod = [MaveSDK sharedInstance].remoteConfiguration.contactsInvitePage.smsInviteSendMethod;

    // If contacts permission already denied, return nil
    NSString *addressBookStatus = [MAVEABUtils addressBookPermissionStatus];
    if (addressBookStatus == MAVEABPermissionStatusDenied) {
        MAVEInfoLog(@"Using fallback invite page b/c address book permission already denied");
        return NO;
    }

    // If not in a supported region, return nil
    if (![self isInSupportedRegionForServerSideSMSInvites]) {
        MAVEInfoLog(@"Using fallback invite page b/c not in supported region for server-side SMS");
        return NO;
    }

    // If configured server-side to turn off contacts invite page, return nil
    if (![self isContactsInvitePageEnabledServerSide]) {
        MAVEInfoLog(@"Using fallback invite page b/c contacts page set to NO server-side");
        return NO;
    }

    // If user data doesn't have a legit user id & first name, can't send server-side SMS
    // so use share page instead
    if (![[MaveSDK sharedInstance].userData isUserInfoOkToSendServerSideSMS]) {
        MAVEInfoLog(@"Fallback to custom share page b/c user info invalid");
        return NO;
    }
    return YES;
}

- (MFMessageComposeViewController *)createClientSMSInvitePage {
    // can't do this if we're going to push the VC instead of display modally
    if ([self.navigationPresentedFormat isEqualToString:MAVEInvitePagePresentFormatPush]) {
        MAVEErrorLog(@"Tried to push the client sms form which doesn't work, need to display the view controller modally to show the client sms compose invite page.");
        return nil;
    }
    return [MAVESharer composeClientSMSInviteToRecipientPhones:nil completionBlock:^(MFMessageComposeViewController *controller,
                                                                                     MessageComposeResult result) {
        switch (result) {
            case MessageComposeResultCancelled:
                [self dismissOnCancel];
                break;
            case MessageComposeResultFailed:
                [self dismissOnCancel];
                break;
            case MessageComposeResultSent:
                [self dismissOnSuccess:1];
        }
    }];
}


#pragma mark - Logic about current conditions
- (BOOL)isInSupportedRegionForServerSideSMSInvites {
    // Right now, we'll only try our address book flow for US devices until we can
    // thoroughly test different countries
    NSString *countryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
    if (   [countryCode isEqualToString:MAVECountryCodeUnitedStates]
        || [countryCode isEqualToString:MAVECountryCodeCanada]) {
        return YES;
    }
    return NO;
}

- (BOOL)isContactsInvitePageEnabledServerSide {
    return [MaveSDK sharedInstance].remoteConfiguration.contactsInvitePage.enabled;
}


#pragma mark - additional setup to view controllers

// View controller and navigation controller custom getters/setters
- (UINavigationController *)activeNavigationController {
    return self.activeViewController.navigationController;
}
- (void)setActiveViewController:(UIViewController *)activeViewController {
    // drop reference to active navigation controller
    _activeNavigationController = nil;
    _activeViewController = activeViewController;
}

- (void)setupNavigationBarForActiveViewController {
    // if our view controller is already a navigation controller, don't
    // need to wrap it
    if ([self.activeViewController isKindOfClass:[UINavigationController class]]) {
        return;
    }

    if (!self.activeViewController.navigationController) {
        [self _embedActiveViewControllerInNewNavigationController];
    }

    [self _styleNavigationItemForActiveViewController];

    if ([self.navigationPresentedFormat isEqualToString:
         MAVEInvitePagePresentFormatModal]) {
        [self _setupNavigationBarButtonsModalStyle];
    } else if ([self.navigationPresentedFormat isEqualToString:
                MAVEInvitePagePresentFormatPush]) {
        [self _setupNavigationBarButtonsPushStyle];
    }
}

- (void)_embedActiveViewControllerInNewNavigationController {
    _activeNavigationController = [[MAVEWrapperNavigationController alloc] initWithRootViewController:self.activeViewController];
}

- (void)_styleNavigationItemForActiveViewController {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
    self.activeViewController.navigationItem.title = displayOptions.navigationBarTitleCopy;
    self.activeViewController.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: displayOptions.navigationBarTitleTextColor,
        NSFontAttributeName: displayOptions.navigationBarTitleFont,
    };
    self.activeViewController.navigationController.navigationBar.barTintColor = displayOptions.navigationBarBackgroundColor;
}

// Setup the single "Cancel" button to close the modal window/return to drawer
- (void)_setupNavigationBarButtonsModalStyle {
    UIBarButtonItem *button = [MaveSDK sharedInstance].displayOptions.navigationBarCancelButton;
    if (!button) {
        button = [[UIBarButtonItem alloc] init];
        button.style = UIBarButtonItemStylePlain;
        button.title = @"Cancel";
    }
    button.target = self;
    button.action = @selector(dismissOnCancel);
    self.activeViewController.navigationItem.leftBarButtonItem = button;
}

- (void)_setupNavigationBarButtonsPushStyle {
    // Back button is optional, if not set ios will set a default
    UIBarButtonItem *backButton = [MaveSDK sharedInstance].displayOptions.navigationBarBackButton;
    if (backButton) {
        backButton.target = self;
        backButton.action = @selector(dismissOnBack);
        self.activeViewController.navigationItem.leftBarButtonItem = backButton;
    }

    // for forward button, we need to build a default if none was given
    UIBarButtonItem *forwardButton = [MaveSDK sharedInstance].displayOptions.navigationBarForwardButton;
    if (!forwardButton) {
        forwardButton = [[UIBarButtonItem alloc] init];
        forwardButton.title = @"Skip";
        forwardButton.style = UIBarButtonItemStylePlain;
    }
    forwardButton.target = self;
    forwardButton.action = @selector(dismissOnForward);
    self.activeViewController.navigationItem.rightBarButtonItem = forwardButton;
}

- (void)replaceActiveViewControllerWithFallbackPage {
    // if displaying pushed on stack, pop then push to replace it on the stack
    //
    // if displaying modally, we can push just it onto our new modal stack b/c
    // the cancel button still dismisses the whole modal navigation controller
    UINavigationController *navigationController = self.activeNavigationController;
    if ([self.navigationPresentedFormat isEqualToString:MAVEInvitePagePresentFormatPush]) {
        [navigationController popViewControllerAnimated:NO];
    }
    MAVEInvitePageType fallbackPageType = [MaveSDK sharedInstance].remoteConfiguration.invitePageChoice.fallbackPageType;
    self.activeViewController = [self createViewControllerOfType:fallbackPageType];
    if (!self.activeViewController) {
        MAVEErrorLog(@"Error, got nil view controller from fallback page type");
        self.activeViewController = [[MAVECustomSharePageViewController alloc] init];
    }

    // We prefer to push the replacement controller onto the navigation stack so that we can still dismiss
    // our bottom level view controller normally. But if the replacement controller is a navigation controller
    // (e.g. client sms dialog) we can't do that so we have to present it on top of the modal
    if ([self.activeViewController isKindOfClass:[UINavigationController class]]) {
        [navigationController presentViewController:self.activeViewController animated:YES completion:nil];
        self.needToUnwindReplacementModalViewController = YES;
    } else {
        [self setupNavigationBarForActiveViewController];
        [navigationController pushViewController:self.activeViewController animated:NO];
    }
}

- (void)dismissModalViewControllersAboveBottomIfAny {
    // If we presented a second view controller over our view controller as a modal,
    // remove it so that we're back to just one view controller displayed that can
    // be dismissed by the application code.
    //
    // This gets triggered for client side sms compose screen fallback
    if (self.needToUnwindReplacementModalViewController) {
        UIViewController *bottomActiveViewController = [self.activeViewController presentingViewController];
        [self.activeViewController dismissViewControllerAnimated:NO completion:nil];
        self.activeViewController = bottomActiveViewController;
        self.needToUnwindReplacementModalViewController = NO;
    }
}

- (void)dismissOnSuccess:(NSUInteger)numberOfInvitesSent {
    [self dismissModalViewControllersAboveBottomIfAny];
    [self.activeViewController.view endEditing:YES];
    if ([self.navigationPresentedFormat isEqualToString:MAVEInvitePagePresentFormatModal]) {
        if (self.navigationCancelBlock) {
            self.navigationCancelBlock(self.activeViewController,
                                       numberOfInvitesSent);
        }
    } else if ([self.navigationPresentedFormat isEqualToString:MAVEInvitePagePresentFormatPush]) {
        if (self.navigationForwardBlock) {
            self.navigationForwardBlock(self.activeViewController,
                                        numberOfInvitesSent);
        }
    }
}

- (void)dismissOnCancel {
    [self dismissModalViewControllersAboveBottomIfAny];
    [self.activeViewController.view endEditing:YES];
    if (self.navigationCancelBlock) {
        self.navigationCancelBlock(self.activeViewController, 0);
    }
}

- (void)dismissOnBack {
    [self.activeViewController.view endEditing:YES];
    if (self.navigationBackBlock) {
        self.navigationBackBlock(self.activeViewController, 0);
    }
}

- (void)dismissOnForward {
    if (self.navigationForwardBlock) {
        self.navigationForwardBlock(self.activeViewController, 0);
    }
}



@end
