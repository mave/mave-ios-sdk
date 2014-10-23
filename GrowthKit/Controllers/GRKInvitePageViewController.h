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

@protocol GRKInvitePageDelegate <NSObject>
@required
- (void)userDidCancel;
- (void)userDidSendInvites;
@optional
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

