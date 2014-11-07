//
//  InvitePage.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "MaveSDK.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEDisplayOptions.h"

@implementation MaveSDK {
    // Controller
    UINavigationController *invitePageNavController;
}

//
// Init and handling shared instance
//

- (MaveSDK *)initWithAppId:(NSString *)appId {
    _appId = appId;
    _displayOptions = [[MAVEDisplayOptions alloc] initWithDefaults];
    return self;
}

static MaveSDK *sharedInstance = nil;

+ (void)setupSharedInstanceWithAppId:(NSString *)appId {
    sharedInstance = [[[self class] alloc] initWithAppId:appId];
}

+ (MaveSDK *)sharedInstance {
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
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    invitePageNavController = [[UINavigationController alloc] initWithRootViewController:ipvc];
    [sourceController presentViewController:invitePageNavController animated:YES completion:nil];
}

@end