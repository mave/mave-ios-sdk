//
//  InvitePage.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "GrowthKit.h"
#import "GRKInvitePageViewController.h"
#import "GRKDisplayOptions.h"

@implementation GrowthKit {
    // Controller
    UINavigationController *invitePageNavController;
}

//
// Init and handling shared instance
//

- (GrowthKit *)initWithAppId:(NSString *)appId {
    _appId = appId;
    _displayOptions = [[GRKDisplayOptions alloc] initWithDefaults];
    return self;
}

static GrowthKit *sharedInstance = nil;

+ (void)setupSharedInstanceWithAppId:(NSString *)appId {
    sharedInstance = [[[self class] alloc] initWithAppId:appId];
}

+ (GrowthKit *)sharedInstance {
    if (sharedInstance == nil) {
        NSLog(@"Error: didn't setup shared instance with app id");
    }
    return sharedInstance;
}

- (void)setUserData:(NSString *)userId firstName:(NSString *)firstName lastName:(NSString *)lastName {
    _currentUserId = userId;
    _currentUserFirstName = firstName;
    _currentUserLastName = lastName;
}


- (void)presentInvitePage:(UIViewController *)sourceController {
    GRKInvitePageViewController *ipvc = [[GRKInvitePageViewController alloc] init];
    invitePageNavController = [[UINavigationController alloc] initWithRootViewController:ipvc];
    [sourceController presentViewController:invitePageNavController animated:YES completion:nil];
}

@end