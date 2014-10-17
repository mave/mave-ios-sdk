//
//  GRKInviteMessageViewController.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRKInviteMessageView.h"
#import "GRKInviteSendingInProgressView.h"

@interface GRKInviteMessageViewController : NSObject

@property UIView *view;
@property GRKInviteMessageView *messageView;
@property GRKInviteSendingInProgressView *sendingInProgressView;

- (GRKInviteMessageViewController *)initAndCreateViewWithFrame:(CGRect)frame;

- (void)switchToSendingInProgressView:(UIView *)superView;
- (void)updateProgressViewFromTimer:(NSTimer *)timer;

@end
