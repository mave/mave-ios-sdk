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

- (UIView *)createContainerAndChildViews;
- (void)setContainerAndChildFramesWithKeyboardSize:(CGSize)kbSize;

// Other business logic
- (void)sendInvites:(id)sender;

// This is called when the view controller is being dismissed, either
// b/c we're done sending invites or the user hit cancel
- (void)cleanupForDismiss;

- (void)dismissAfterCancel:(id)sender;


@end
