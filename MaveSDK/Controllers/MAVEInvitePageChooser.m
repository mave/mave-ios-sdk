//
//  MAVEInvitePageChooser.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import "MAVEInvitePageChooser.h"
#import "MAVEConstants.h"
#import "MAVEABUtils.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEShareActions.h"

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


    

    return nil;
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

#pragma mark - helpers to create the kinds of view controllers

- (UIViewController *)createAddressBookInvitePage {
    return [[MAVEInvitePageViewController alloc] init];
}

- (UIViewController *)createCustomShareInvitePage {
    return nil;
}

@end
