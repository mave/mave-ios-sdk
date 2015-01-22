//
//  AppDelegate.m
//  DemoApp
//
//  Created by dannycosson on 10/10/14.
//
//

#import "AppDelegate.h"
#import "MaveSDK.h"
#import "MAVEIDUtils.h"

#define MAVEDemoApplicationID @"12345"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [MaveSDK setupSharedInstanceWithApplicationID:MAVEDemoApplicationID];
    MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:@"1"
                                                        firstName:@"Example"
                                                         lastName:@"Person"
                                                            email:@"foo@ex.com"
                                                            phone:@"18085551234"];
    [[MaveSDK sharedInstance] identifyUser:userData];

    ///
    /// Display customizations
    ///

    // Set some variables for our app's common fonts and colors
    UIColor *green = [[UIColor alloc] initWithRed:43.0/255 green:202.0/255
                                             blue:125.0/255 alpha:1.0];
    UIColor *white = [[UIColor alloc] initWithWhite:1.0 alpha:1.0];
    UIColor *black = [[UIColor alloc] initWithWhite:0.15 alpha: 1.0];
    UIColor *gray = [[UIColor alloc] initWithWhite:0.50 alpha: 1.0];
    UIColor *lightGray = [[UIColor alloc] initWithWhite:0.96 alpha: 1.0];
    UIFont *font1 = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:17];
    UIFont *font1Bold = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:17];
    UIFont *font1Smaller = [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:14];
    UIFont *font1SmallerBold = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:14];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Back";
    backButton.tintColor = white;

    // Customize the Mave invite page
    MaveSDK *mave = [MaveSDK sharedInstance];

    // Navigation bar options
    mave.displayOptions.navigationBarTitleCopy = @"Invite friends";
    mave.displayOptions.navigationBarTitleFont = font1Bold;
    mave.displayOptions.navigationBarTitleTextColor = black;
    mave.displayOptions.navigationBarBackgroundColor = lightGray;
    // the cancel button can be any custom UIBarButtonItem, but note
    // that the action and target will be ignored since we call the
    // dismissalBlock you passed us instead
    mave.displayOptions.navigationBarCancelButton = backButton;

    // Invite explanation options
//    mave.displayOptions.inviteExplanationCopy = @"";
//    mave.displayOptions.inviteExplanationCopy = @"Short line";
//        @"Invite friends to DemoApp!\nGet $20 for each person that signs up.";
    mave.displayOptions.inviteExplanationFont = font1SmallerBold;
    mave.displayOptions.inviteExplanationTextColor = black;
    mave.displayOptions.inviteExplanationCellBackgroundColor = green;

    // Contacts table options
    mave.displayOptions.contactNameFont = font1;
    mave.displayOptions.contactNameTextColor = black;
    mave.displayOptions.contactDetailsFont = font1Smaller;
    mave.displayOptions.contactDetailsTextColor = gray;
    mave.displayOptions.contactSeparatorColor = lightGray;
    mave.displayOptions.contactCellBackgroundColor = white;
    mave.displayOptions.contactCheckmarkColor = green;

    // Contacts table section header & index options
    mave.displayOptions.contactSectionHeaderFont = font1Smaller;
    mave.displayOptions.contactSectionHeaderTextColor = black;
    mave.displayOptions.contactSectionHeaderBackgroundColor = lightGray;
    mave.displayOptions.contactSectionIndexColor = black;
    mave.displayOptions.contactSectionIndexBackgroundColor = [UIColor colorWithWhite:1 alpha:0];

    // Message and Send section options
    mave.displayOptions.messageFieldFont = [UIFont systemFontOfSize:16];
    mave.displayOptions.messageFieldTextColor = black;
    mave.displayOptions.messageFieldBackgroundColor = white;
    mave.displayOptions.sendButtonCopy = @"Send";
    mave.displayOptions.sendButtonFont = font1Bold;
    mave.displayOptions.sendButtonTextColor = green;
    mave.displayOptions.bottomViewBorderColor = gray;
    mave.displayOptions.bottomViewBackgroundColor = lightGray;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
