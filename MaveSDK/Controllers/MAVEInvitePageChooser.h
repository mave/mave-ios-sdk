//
//  MAVEInvitePageChooser.h
//  MaveSDK
//
//  Class in charge of choosing which invite page to display.
//  Decides based on remote-configured options, current address book permissions,
//  device's country, etc.
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVEInvitePageChooser : NSObject

// Choose which invite page to present and initialize is view controller
- (UIViewController *)chooseAndCreateInvitePageViewController;

// Helpers for business logic
- (BOOL)isInSupportedRegionForServerSideSMSInvites;
- (BOOL)isContactsInvitePageEnabledServerSide;

// Create custom view controllers
- (UIViewController *)createAddressBookInvitePage;
- (UIViewController *)createCustomShareInvitePage;

// Alter view controllers
- (UINavigationController *)embedInNavigationController:(UIViewController *)viewController;
- (void)setupNavigationBar:(UIViewController *)viewController
       leftBarButtonTarget:(id)target
       leftBarButtonAction:(SEL)action;

@end
