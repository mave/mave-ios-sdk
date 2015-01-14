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

@implementation MAVEInvitePageChooser

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
