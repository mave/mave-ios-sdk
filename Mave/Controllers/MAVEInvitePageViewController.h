//
//  InvitePageViewController.h
//  MaveDevApp
//
//  Created by dannycosson on 10/1/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEABTableViewController.h"
#import "MAVEInviteMessageViewController.h"
#import "MAVEHTTPManager.h"

// This protocol must be implemented to dismiss the invite page view controller and return
//   the user to your application.
// You can also run custom code based on whether or not the user sent any invites.
@protocol MAVEInvitePageDelegate <NSObject>

@required
// Indicates that invites were sent successfully
- (void)userDidSendInvites;

// Indicates that the user hit cancel without sending any invites.
- (void)userDidCancel;

@end



@interface MAVEInvitePageViewController : UIViewController <MAVEABTableViewAdditionalDelegate>

@property (nonatomic) id <MAVEInvitePageDelegate> delegate;
@property (nonatomic) MAVEABTableViewController *ABTableViewController;
@property (nonatomic) MAVEInviteMessageViewController *inviteMessageViewController;

// Helpers for keeping track of keyboard for frame resizing
@property (atomic) CGRect keyboardFrame; // keep track to use when resizing frame
@property (atomic) BOOL isKeyboardVisible;

// Setup self and children
- (instancetype)initWithDelegate:(id <MAVEInvitePageDelegate>)delegate;
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

