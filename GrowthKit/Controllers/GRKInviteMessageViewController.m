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

@implementation GRKInviteMessageViewController

- (GRKInviteMessageViewController *)initAndCreateViewWithFrame:(CGRect)frame {
    self = [self init];
    if (self) {
        self.view = [[GRKInviteMessageView alloc] initCustomWithFrame:frame];
    }
    return self;
}

@end
