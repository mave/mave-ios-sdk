//
//  InvitePageViewController.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/1/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEABTableViewController.h"
#import "MAVEInviteExplanationView.h"
#import "MAVEInviteMessageContainerView.h"

extern NSString * const MAVEInvitePageTypeContactList;
extern NSString * const MAVEInvitePageTypeNoneNeedContactsPermission;
extern NSString * const MAVEInvitePageTypeCustomShare;
extern NSString * const MAVEInvitePageTypeNativeShareSheet;


@interface MAVEInvitePageViewController : UIViewController <MAVEABTableViewAdditionalDelegate>

@property (strong, nonatomic) MAVEABTableViewController *ABTableViewController;
@property (strong, nonatomic) MAVEInviteExplanationView *inviteExplanationView;
@property (strong, nonatomic) MAVEInviteMessageContainerView *inviteMessageContainerView;

// Helpers for keeping track of keyboard for frame resizing
@property (atomic) CGRect keyboardFrame; // keep track to use when resizing frame
@property (atomic) BOOL isKeyboardVisible;

// Setup self and children
- (UIView *)createAddressBookInviteView;
- (UIView *)createNoAddressBookPermissionView;
- (UIView *)createEmptyFallbackView;

- (BOOL)shouldDisplayInviteMessageView;
- (void)presentShareSheet;
- (void)layoutInvitePageViewAndSubviews;
- (void)determineAndSetViewBasedOnABPermissions;

// Invite Sending
- (void)sendInvites;
- (void)showErrorAndResetAfterSendInvitesFailure:(NSError *)error;

// Methods to dismiss self after user done sending invites or user hit cancel
- (void)dismissSelf:(unsigned int)numberOfInvitesSent;
- (void)dismissAfterCancel;
@end