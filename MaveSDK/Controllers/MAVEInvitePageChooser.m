//
//  MAVEInvitePageChooser.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import "MAVEInvitePageChooser.h"
#import "MAVEABUtils.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEShareActions.h"

@implementation MAVEInvitePageChooser

- (UIViewController *)chooseAndCreateInvitePageViewController {
    // If contacts permission already denied, load the share page
    if ([MAVEABUtils addressBookPermissionStatus] == MAVEABPermissionStatusDenied) {
        return [self createCustomShareInvitePage];
    }
    return nil;
}


#pragma mark - choosing logic helpers



#pragma mark - helpers to create the kinds of view controllers

- (UIViewController *)createAddressBookInvitePage {
    return [[MAVEInvitePageViewController alloc] init];
}

- (UIViewController *)createCustomShareInvitePage {
    return nil;
}

@end
