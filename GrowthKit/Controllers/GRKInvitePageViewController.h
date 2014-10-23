//
//  InvitePageViewController.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/1/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRKABTableViewController.h"
#import "GRKInviteMessageViewController.h"
#import "GRKHTTPManager.h"

// This protocol must be implemented to dismiss the invite page view controller and return
//   the user to your application.
// You can also run custom code based on whether or not the user sent any invites.
@protocol GRKInvitePageDelegate <NSObject>

@required
// Indicates that invites were sent successfully
- (void)userDidSendInvites;

// Indicates that the user hit cancel without sending any invites.
- (void)userDidCancel;

@optional
// Return a custom button to use for the top left of the invite page navigation bar.
// Useful to set a custom icon, at a minimum you'd want a different icon for
//   presenting the invite page as a modal vs pushing onto a navigation stack vs using
//   a custom drawer controller or something.
//
// Any target & action set on the bar button item will be ignored, instead this library
// will call its own cleanup methods and then call your `userDidCancel` method.
- (UIBarButtonItem *)cancelBarButtonItem;

@end



@interface GRKInvitePageViewController : UIViewController

@property (nonatomic) id <GRKInvitePageDelegate> delegate;
@property (nonatomic) GRKABTableViewController *ABTableViewController;
@property (nonatomic) GRKInviteMessageViewController *inviteMessageViewController;

// Helpers for keeping track of keyboard for frame resizing
@property (atomic) CGRect keyboardFrame; // keep track to use when resizing frame
@property (atomic) BOOL isKeyboardVisible;

- (instancetype)initWithDelegate:(id <GRKInvitePageDelegate>)delegate;
- (UIView *)createAddressBookInviteView;
- (UIView *)createEmptyFallbackView;
- (void)setOwnAndSubviewFrames;
- (void)setupNavigationBar;
- (void)determineAndSetViewBasedOnABPermissions;

// Other business logic
- (void)sendInvites;
- (void)showErrorAndResetAfterSendInvitesFailure:(NSError *)error;

// This is called when the view controller is being dismissed.
// Called just before the delegate method for cancel or did send.
- (void)cleanupForDismiss;
@end

