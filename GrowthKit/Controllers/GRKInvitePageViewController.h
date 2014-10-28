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

@end



@interface GRKInvitePageViewController : UIViewController <GRKABTableViewAdditionalDelegate>

@property (nonatomic) id <GRKInvitePageDelegate> delegate;
@property (nonatomic) GRKABTableViewController *ABTableViewController;
@property (nonatomic) GRKInviteMessageViewController *inviteMessageViewController;

// Helpers for keeping track of keyboard for frame resizing
@property (atomic) CGRect keyboardFrame; // keep track to use when resizing frame
@property (atomic) BOOL isKeyboardVisible;

// Setup self and children
- (instancetype)initWithDelegate:(id <GRKInvitePageDelegate>)delegate;
- (UIView *)createAddressBookInviteView;
- (UIView *)createEmptyFallbackView;
- (void)setupNavigationBar;
- (void)setOwnAndSubviewFrames;
- (void)determineAndSetViewBasedOnABPermissions;

// Invite Sending
- (void)sendInvites;
- (void)showErrorAndResetAfterSendInvitesFailure:(NSError *)error;

// This is called when the view controller is being dismissed.
// Called just before the delegate method for cancel or did send.
- (void)cleanupForDismiss;
@end

