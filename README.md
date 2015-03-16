# Mave iOS SDK

## Usage

You can see it in action (without any server-side interactions) in the included demo app. To run it:
 - `pod install` to pull the required dependencies
 - then open `MaveSDK.xcworkspace` in xcode and build the `DemoApp` Target.

## Quick Integration

See full docs [here](http://mave.io/docs).

The Mave SDK is available through CocoaPods. To install it, simply add the following line to your Podfile:

```objc
pod "MaveSDK"
```


Then, initialize the SDK in `applicationDidFinishLaunchingWithOptions:`

```objc
#import <MaveSDK.h>;

#define MAVE_SDK_APPLICATION_ID @"YOUR_APPLICATION_ID"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MaveSDK setupSharedInstanceWithApplicationID:MAVE_SDK_APPLICATION_ID];

    // The rest of your app's setup code
}
```


Then, use the following code to present the page (e.g. in the action for clicking on an "invite friends" button)


```objc
MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:@"1"
                                                    firstName:@"Example"
                                                     lastName:@"Person"];
[[MaveSDK sharedInstance] identifyUser:userData];
[[MaveSDK sharedInstance] presentInvitePageModallyWithBlock:^(UIViewController *inviteController) {
    // Code to present Mave's view controller from yours, e.g:
    // [self presentViewController:inviteController animated:YES completion:nil];
} dismissBlock:^(UIViewController *controller, NSUInteger numberOfInvitesSent) {
    // Code to transition back to your view controller after Mave's
    // is dismissed (sent invites or cancelled), e.g:
    // [controller dismissViewControllerAnimated:YES completion:nil];
} inviteContext:@"default"];
    // Passing an inviteContext allows you to track where a user came
    // from to get to the invite page. (e.g. "drawer menu", "profile")
    // It's used for analytics, not functionality.
```


## Author

© Mave Technologies 2015

support@mave.io

## License

This SDK is released under a proprietary license, to use it in your released application you need to be using the Mave platform (sign up for our beta at [mave.io](http://app.mave.io/beta/signup)). See the LICENSE file.
