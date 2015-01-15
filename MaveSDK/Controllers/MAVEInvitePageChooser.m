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
#import "MAVEConstants.h"
#import "MAVEABUtils.h"
#import "MAVERemoteConfiguration.h"
#import "MAVEInvitePageViewController.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVEDisplayOptions.h"

NSString * const MAVEInvitePageTypeContactList = @"contact_list";
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

- (instancetype)initForPushPresentWithBackBlock:(MAVEInvitePageDismissBlock)backBlock
                                      nextBlock:(MAVEInvitePageDismissBlock)nextBlock {
    if (self = [super init]) {
        self.navigationPresentedFormat = MAVEInvitePagePresentFormatPush;
        self.navigationBackBlock = backBlock;
        self.navigationForwardBlock = nextBlock;
    }
    return self;
}


- (UIViewController *)chooseAndCreateInvitePageViewController {
    // If contacts permission already denied, load the share page
    NSString *addressBookStatus = [MAVEABUtils addressBookPermissionStatus];
    if (addressBookStatus == MAVEABPermissionStatusDenied) {
        MAVEInfoLog(@"Fallback to Custom Share invite page b/c address book permission already denied");
        return [self createCustomShareInvitePage];
    }

    // If not in a supported region, load the share page
    if (![self isInSupportedRegionForServerSideSMSInvites]) {
        return [self createCustomShareInvitePage];
        MAVEInfoLog(@"Fallback to Custom Share invite page b/c not in supported region for server-side SMS");
    }

    // If configured server-side to turn off contacts invite page, use share page instead
    if (![self isContactsInvitePageEnabledServerSide]) {
        MAVEInfoLog(@"Fallback to custom share page b/c contacts page set to NO server-side");
        return [self createCustomShareInvitePage];
    }

    // If user data doesn't have a legit user id & first name, can't send server-side SMS
    // so use share page instead
    if (![[MaveSDK sharedInstance].userData isUserInfoOkToSendServerSideSMS]) {
        MAVEInfoLog(@"Fallback to custom share page b/c user info invalid");
        return [self createCustomShareInvitePage];
    }

    // otherwise we can load the address book invite page
    MAVEInfoLog(@"Displaying address book invite page");
    return [self createAddressBookInvitePage];
}


#pragma mark - Logic about current conditions
- (BOOL)isInSupportedRegionForServerSideSMSInvites {
    // Right now, we'll only try our address book flow for US devices until we can
    // thoroughly test different countries
    NSString *countryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
    if ([countryCode isEqualToString:MAVECountryCodeUnitedStates]) {
        return YES;
    }
    return NO;
}

- (BOOL)isContactsInvitePageEnabledServerSide {
    return [MaveSDK sharedInstance].remoteConfiguration.contactsInvitePage.enabled;
}


#pragma mark - helpers to create the kinds of view controllers

- (UIViewController *)createAddressBookInvitePage {
    self.activeViewController = [[MAVEInvitePageViewController alloc] init];
    return self.activeViewController;
}

- (UIViewController *)createCustomShareInvitePage {
    self.activeViewController = [[MAVECustomSharePageViewController alloc] init];
    return self.activeViewController;
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


- (UINavigationController *)embedInNavigationController:(UIViewController *)viewController {
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:viewController];
    return nvc;
}

- (void)setupNavigationBar:(UIViewController *)viewController
       leftBarButtonTarget:(id)target
       leftBarButtonAction:(SEL)action {
    // if no navigation controller, no need to set up
    if (!viewController.navigationController) {
        return;
    }

//    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
//
//    viewController.navigationItem.title = displayOptions.navigationBarTitleCopy;
//    viewController.navigationController.navigationBar.titleTextAttributes = @{
//        NSForegroundColorAttributeName: displayOptions.navigationBarTitleTextColor,
//        NSFontAttributeName: displayOptions.navigationBarTitleFont,
//    };
//    viewController.navigationController.navigationBar.barTintColor = displayOptions.navigationBarBackgroundColor;
//
//    UIBarButtonItem *cancelBarButtonItem = displayOptions.navigationBarCancelButton;
//    cancelBarButtonItem.target = target;
//    cancelBarButtonItem.action = action;
//    [viewController.navigationItem setLeftBarButtonItem:cancelBarButtonItem];

//    viewController.navigationItem.leftBarButtonItem.target = target;
//    viewController.navigationItem.leftBarButtonItem.action = action;
//
//    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
//                                                                 style:UIBarButtonItemStylePlain
//                                                                target:self
//                                                                action:@selector(navigationNext)];
//    [viewController.navigationItem setRightBarButtonItem:nextItem];

}

- (void)setupNavigationBarForActiveViewController {
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
    _activeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activeViewController];
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
        button.title = @"Cancel";
        button.style = UIBarButtonItemStylePlain;
    }
    button.target = self;
    button.action = @selector(handleCancelAction);
    self.activeViewController.navigationItem.leftBarButtonItem = button;
}

- (void)_setupNavigationBarButtonsPushStyle {
    // Back button is optional, if not set ios will set a default
    UIBarButtonItem *backButton = [MaveSDK sharedInstance].displayOptions.navigationBarBackButton;
    if (backButton) {
        backButton.target = self;
        backButton.action = @selector(handleBackAction);
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
    forwardButton.action = @selector(handleForwardAction);
    self.activeViewController.navigationItem.rightBarButtonItem = forwardButton;
}

- (void)handleCancelAction {

}

- (void)handleBackAction {
    if ([MaveSDK sharedInstance].invitePageDismissBlock) {
        [MaveSDK sharedInstance].invitePageDismissBlock(self.activeViewController, 0);
    }
}

- (void)handleForwardAction {
    if ([MaveSDK sharedInstance].invitePageForwardBlock) {
        [MaveSDK sharedInstance].invitePageForwardBlock(self.activeViewController, 0);
    }
}



@end
