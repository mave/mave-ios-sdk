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
#import "MAVEInvitePageViewController.h"
#import "MAVEShareActions.h"
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

    // If configured server-side to load share page, do that


    // otherwise we can load the address book invite page
    return [self createAddressBookInvitePage];
}


#pragma mark - choosing logic helpers
- (BOOL)isInSupportedRegionForServerSideSMSInvites {
    // Right now, we'll only try our address book flow for US devices until we can
    // thoroughly test different countries
    NSString *countryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
    if ([countryCode isEqualToString:MAVECountryCodeUnitedStates]) {
        return YES;
    }
    return NO;

}

#pragma mark - helpers to create the kinds of view controllers & alter them

- (UIViewController *)createAddressBookInvitePage {
    return [[MAVEInvitePageViewController alloc] init];
}

- (UIViewController *)createCustomShareInvitePage {
    return [[MAVEShareActions alloc] init];
}

- (void)setupNavigationBar:(UIViewController *)viewController {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    viewController.navigationItem.title = displayOptions.navigationBarTitleCopy;
    viewController.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName: displayOptions.navigationBarTitleTextColor,
                                                                    NSFontAttributeName: displayOptions.navigationBarTitleFont,
                                                                    };
    viewController.navigationController.navigationBar.barTintColor = displayOptions.navigationBarBackgroundColor;

    UIBarButtonItem *cancelBarButtonItem = displayOptions.navigationBarCancelButton;
    cancelBarButtonItem.target = self;
    cancelBarButtonItem.action = @selector(dismissAfterCancel);
    [viewController.navigationItem setLeftBarButtonItem:cancelBarButtonItem];
}



@end
