//
//  MAVEInvitePageChooser.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import "MaveSDK.h"
#import "MAVEInvitePageChooser.h"
#import "MAVEConstants.h"
#import "MAVEABUtils.h"
#import "MAVERemoteConfiguration.h"
#import "MAVEInvitePageViewController.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVEDisplayOptions.h"

@implementation MAVEInvitePageChooser

- (UIViewController *)chooseAndCreateInvitePageViewController {
    // If contacts permission already denied, load the share page
    NSString *addressBookStatus = [MAVEABUtils addressBookPermissionStatus];
    if (addressBookStatus == MAVEABPermissionStatusDenied) {
        return [self createCustomShareInvitePage];
    }

    // If not in a supported region, load the share page
    if (![self isInSupportedRegionForServerSideSMSInvites]) {
        return [self createCustomShareInvitePage];
    }

    // If configured server-side to tur off contacts invite page do that
    if (![self isContactsInvitePageEnabledServerSide]) {
        return [self createCustomShareInvitePage];
    }

    // otherwise we can load the address book invite page
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
    MAVERemoteConfiguration *remoteConfig = [[MaveSDK sharedInstance].remoteConfigurationBuilder createObjectSynchronousWithTimeout:0];
    return remoteConfig.contactsInvitePage.enabled;
}


#pragma mark - helpers to create the kinds of view controllers

- (UIViewController *)createAddressBookInvitePage {
     return [[MAVEInvitePageViewController alloc] init];
}

- (UIViewController *)createCustomShareInvitePage {
    return [[MAVECustomSharePageViewController alloc] init];
}

#pragma mark - additional setup to view controllers

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

    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    viewController.navigationItem.title = displayOptions.navigationBarTitleCopy;
    viewController.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: displayOptions.navigationBarTitleTextColor,
        NSFontAttributeName: displayOptions.navigationBarTitleFont,
    };
    viewController.navigationController.navigationBar.barTintColor = displayOptions.navigationBarBackgroundColor;

    UIBarButtonItem *cancelBarButtonItem = displayOptions.navigationBarCancelButton;
    cancelBarButtonItem.target = target;
    cancelBarButtonItem.action = action;
    [viewController.navigationItem setLeftBarButtonItem:cancelBarButtonItem];
}



@end
