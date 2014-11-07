//
//  InvitePageViewController.h
//  MaveDevApp
//
//  Created by dannycosson on 10/1/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEABTableViewController.h"

@interface MAVEInvitePageViewController : UIViewController

- (UIView *)createContainerAndChildViews;
- (void)setContainerAndChildFramesWithKeyboardSize:(CGSize)kbSize;

// This is called when the view controller is being dismissed, either
// b/c we're done sending invites or the user hit cancel
- (void)cleanupForDismiss;

- (void)dismissAfterCancel:(id)sender;

@end
