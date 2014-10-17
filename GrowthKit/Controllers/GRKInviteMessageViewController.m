//
//  GRKInviteMessageViewController.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//


#import "AFNetworking.h"
#import "GrowthKit.h"
#import <UIKit/UIKit.h>
#import "GRKInviteMessageViewController.h"
#import "GRKInviteMessageView.h"
#import "GRKInviteSendingInProgressView.h"

@implementation GRKInviteMessageViewController

- (GRKInviteMessageViewController *)initAndCreateViewWithFrame:(CGRect)frame {
    self = [self init];
    if (self) {
        self.messageView = [[GRKInviteMessageView alloc] initCustomWithFrame:frame];
        self.sendingInProgressView = [[GRKInviteSendingInProgressView alloc] initWithFrame:frame];
        self.view = (UIView *)self.messageView;
    }
    return self;
}

- (void)switchToSendingInProgressView:(UIView *)superView {
    [self.view removeFromSuperview];
    self.view = self.sendingInProgressView;
    [superView addSubview:self.view];
    
    [NSTimer scheduledTimerWithTimeInterval:0.05
                                     target:self
                                   selector:@selector(updateProgressViewFromTimer:)
                                   userInfo:@{}
                                    repeats:YES];
    
}

- (void)updateProgressViewFromTimer:(NSTimer *)timer {
    float newProgress = self.sendingInProgressView.progressView.progress + 0.02;
    [self.sendingInProgressView.progressView setProgress:newProgress animated:YES];
    if (newProgress >= 1.0) {
        [timer invalidate];
    }
}


@end
