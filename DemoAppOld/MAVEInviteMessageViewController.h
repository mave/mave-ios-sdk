//
//  MAVEInviteMessageViewController.h
//  MaveDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAVEInviteMessageView.h"

@interface MAVEInviteMessageViewController : NSObject

@property (weak, nonatomic) MAVEInvitePageViewController *delegate;
@property (weak, nonatomic) NSSet *selectedPhones;
@property UITextView *messageTextField;
@property MAVEInviteMessageView *view;

- (MAVEInviteMessageViewController *)initAndCreateViewWithFrame:(CGRect)frame
                                              delegate:(MAVEInvitePageViewController *)delegate
                                        selectedPhones:(NSMutableSet *)selectedPhones;
- (void)sendInvites:(id)sender;

@end
