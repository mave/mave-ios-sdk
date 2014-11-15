//
//  MAVEInviteMessageViewController.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//


#import "MaveSDK.h"
#import <UIKit/UIKit.h>
#import "MAVEInviteMessageViewController.h"
#import "MAVEInviteMessageView.h"
#import "MAVEInviteSendingProgressView.h"

@implementation MAVEInviteMessageViewController

- (instancetype)initAndCreateView {
    self = [self init];
    if (self) {
        self.messageView = [[MAVEInviteMessageView alloc] init];
        self.view = (UIView *)self.messageView;
    }
    return self;
}

- (void)switchToSendingInProgressView:(UIView *)superView {
    if (!self.sendingInProgressView) {
        self.sendingInProgressView = [[MAVEInviteSendingProgressView alloc] initWithFrame:self.view.frame];
    }
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
