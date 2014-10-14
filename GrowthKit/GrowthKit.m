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
#import "GRKHTTPManager.h"

@implementation GrowthKit {
    // Controller
    UINavigationController *invitePageNavController;
}

//
// Init and handling shared instance
//

- (GrowthKit *)initWithAppId:(NSString *)appId {
    self = [self init];
    if (self) {
        _appId = appId;
        _displayOptions = [[GRKDisplayOptions alloc] initWithDefaults];
        _HTTPManager = [[GRKHTTPManager alloc] initWithApplicationId:appId];
    }
    return self;
}

static GrowthKit *sharedInstance = nil;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID {
    sharedInstance = [[[self class] alloc] initWithAppId:applicationID];
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