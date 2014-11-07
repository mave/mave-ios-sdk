//
//  MAVEInviteMessageViewController.m
//  MaveDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//


#import "Mave.h"
#import <UIKit/UIKit.h>
#import "MAVEInviteMessageViewController.h"
#import "MAVEInviteMessageView.h"
#import "MAVEInviteSendingProgressView.h"

@implementation MAVEInviteMessageViewController

- (MAVEInviteMessageViewController *)initAndCreateViewWithFrame:(CGRect)frame {
    self = [self init];
    if (self) {
        self.messageView = [[MAVEInviteMessageView alloc] initWithFrame:frame];
        self.sendingInProgressView = [[MAVEInviteSendingProgressView alloc] initWithFrame:frame];
        self.view = (UIView *)self.messageView;
    }
    return self;
}

- (void)switchToSendingInProgressView:(UIView *)superView {
    [self.view removeFromSuperview];
    self.view = self.sendingInProgressView;
    [superView addSubview:self.view];
    [self.sendingInProgressView startTimedProgress];
}

- (void)switchToInviteMessageView:(UIView *)superView {
    [self.view removeFromSuperview];
    self.view = self.messageView;
    [superView addSubview:self.view];
}

@end
