//
//  MAVEInviteMessageViewController.h
//  MaveDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAVEInviteMessageView.h"
#import "MAVEInviteSendingProgressView.h"

@interface MAVEInviteMessageViewController : NSObject

@property UIView *view;
@property MAVEInviteMessageView *messageView;
@property MAVEInviteSendingProgressView *sendingInProgressView;

- (MAVEInviteMessageViewController *)initAndCreateViewWithFrame:(CGRect)frame;

- (void)switchToSendingInProgressView:(UIView *)superView;
- (void)switchToInviteMessageView:(UIView *)superView;

@end
