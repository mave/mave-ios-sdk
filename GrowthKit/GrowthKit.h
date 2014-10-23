//
//  InvitePage.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRKInvitePageViewController.h"
#import "GRKDisplayOptions.h"

@class GRKHTTPManager;

@interface GrowthKit : NSObject

@property (nonatomic, strong) GRKInvitePageViewController *viewController;
@property (nonatomic, strong) GRKDisplayOptions *displayOptions;
@property (nonatomic, strong) GRKHTTPManager *HTTPManager;

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *currentUserId;
@property (nonatomic, strong) NSString *currentUserFirstName;
@property (nonatomic, strong) NSString *currentUserLastName;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID;
+ (instancetype)sharedInstance;

// Ability to reset the object in tests
# if DEBUG
+ (void)resetSharedInstanceForTesting;
#endif

- (void)setUserData:(NSString *)userId
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName;

- (void)registerAppOpen;
- (void)registerNewUserSignup:(NSString *)userId
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        email:(NSString *)email
                        phone:(NSString *)phone;

- (void)presentInvitePage:(UIViewController *)sourceController animated:(BOOL)animated;
- (UIViewController *)invitePageViewControllerWithDelegate:(id <GRKInvitePageDelegate>) delegate;

@end
