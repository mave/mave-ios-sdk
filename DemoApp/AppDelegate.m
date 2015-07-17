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
    [self setupMaveSDK];
//    [self customizeMaveInvitePage];
    return YES;
}

- (void)setupMaveSDK {
    [MaveSDK setupSharedInstanceWithApplicationID:MAVEDemoApplicationID];

    MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:@"1"
                                                        firstName:@"Example"
                                                         lastName:@"Person"];
    [[MaveSDK sharedInstance] identifyUser:userData];
}

- (void)customizeMaveInvitePage {
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;

    // Navigation bar
    opts.statusBarStyle = UIStatusBarStyleDefault;
    opts.navigationBarTitleCopy = @"Invite friends";
    opts.navigationBarTitleFont = [UIFont systemFontOfSize:20];
    opts.navigationBarTitleTextColor = [UIColor whiteColor];
    opts.navigationBarBackgroundColor = [UIColor orangeColor];
    // Set the cancel button if displaying the page modally, or the
    // back and forward buttons if pushing onto a navigation stack.
    // (note the button target & actions are ignored, we call your
    // dismiss/back/forward blocks instead)
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] init];
    cancelButton.title = @"Cancel";
    cancelButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    opts.navigationBarCancelButton = cancelButton;
    // opts.navigationBarBackButton = ...
    // opts.navigationBarForwardButton = ...

    // Tint color on the page
    opts.contactsInvitePageTintColor = [UIColor orangeColor];

    // Share page (available to set as the fallback if contacts
    //   invite page can't be displayed)
    opts.sharePageBackgroundColor = [UIColor whiteColor];
    opts.sharePageIconColor = [UIColor orangeColor];
    opts.sharePageIconFont = [UIFont systemFontOfSize:12];
    opts.sharePageIconTextColor = [UIColor orangeColor];
    opts.sharePageExplanationFont = [UIFont systemFontOfSize:16];
    opts.sharePageExplanationTextColor = [UIColor grayColor];
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
