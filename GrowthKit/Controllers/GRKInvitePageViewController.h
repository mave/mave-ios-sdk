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

@interface GRKInvitePageViewController : UIViewController

@property (nonatomic) GRKABTableViewController *ABTableViewController;
@property (nonatomic) GRKInviteMessageViewController *inviteMessageViewController;

// Helpers for keeping track of keyboard for frame resizing
@property (atomic) CGRect keyboardFrame; // keep track to use when resizing frame
@property (atomic) BOOL isKeyboardVisible;

- (UIView *)createAddressBookInviteView;
- (UIView *)createEmptyFallbackView;
- (void)setOwnAndSubviewFrames;
- (void)setupNavigationBar;
- (void)determineAndSetViewBasedOnABPermissions;

// Other business logic
- (void)sendInvites;
- (void)showErrorAndResetAfterSendInvitesFailure:(NSError *)error;

// This is called when the view controller is being dismissed, either
// b/c we're done sending invites or the user hit cancel
- (void)cleanupForDismiss;

- (void)dismissAfterCancel:(id)sender;


@end
