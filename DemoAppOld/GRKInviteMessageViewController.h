//
//  GRKInviteMessageViewController.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRKInviteMessageView.h"

@interface GRKInviteMessageViewController : NSObject

@property (weak, nonatomic) GRKInvitePageViewController *delegate;
@property (weak, nonatomic) NSSet *selectedPhones;
@property UITextView *messageTextField;
@property GRKInviteMessageView *view;

- (GRKInviteMessageViewController *)initAndCreateViewWithFrame:(CGRect)frame
                                              delegate:(GRKInvitePageViewController *)delegate
                                        selectedPhones:(NSMutableSet *)selectedPhones;
- (void)sendInvites:(id)sender;

@end
