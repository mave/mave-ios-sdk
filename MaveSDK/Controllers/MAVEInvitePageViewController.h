//
//  InvitePageViewController.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/1/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEABTableViewController.h"
#import "MAVEInviteMessageContainerView.h"
#import "MAVEInviteTableHeaderView.h"


@interface MAVEInvitePageViewController : UIViewController <MAVEABTableViewAdditionalDelegate>

@property (strong, nonatomic) MAVEABTableViewController *ABTableViewController;
@property (strong, nonatomic) MAVEInviteMessageContainerView *inviteMessageContainerView;

// Helpers for keeping track of keyboard for frame resizing
@property (atomic) CGRect keyboardFrame; // keep track to use when resizing frame
@property (atomic) BOOL isKeyboardVisible;

// Setup self and children
- (UIView *)createAddressBookInviteView;

- (BOOL)shouldDisplayInviteMessageView;
- (void)presentShareSheet;
- (void)layoutInvitePageViewAndSubviews;

- (void)determineAndSetViewBasedOnABPermissions;

// Helper to manipulate contacts to also show suggested invites.
// Based on the current state, we might
//   - already have suggestions to display
//   - already know we don't have suggestions to display
//   - still be waiting for api response to return 0 or more suggestions
- (void)buildContactsToUseAtPageRender:(NSDictionary **)suggestedContactsReturnVal
          addSuggestedOnDelayWhenReady:(BOOL *)addSuggestedLaterReturnVal
               fromIndexedContactsDict:(NSDictionary *)indexedContacts;

// Invite Sending
- (void)sendInvites;
- (void)showErrorAndResetAfterSendInvitesFailure:(NSError *)error;

// Methods to dismiss self after user done sending invites or user hit cancel
- (void)dismissSelf:(NSUInteger)numberOfInvitesSent;
@end