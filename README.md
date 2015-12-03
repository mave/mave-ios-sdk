Unfortunately, Mave the service has shut down as of Dec 2015.

This library is still functional as a stand-alone invite or share page, but the Mave-provided services such as as SMS invite delivery, the stats dashboard, and suggested invites are no longer available.

The code is now open-source under an MIT license, so feel free to use it as you please.

# Mave iOS SDK

[![Build Status](https://travis-ci.org/mave/mave-ios-sdk.svg?branch=master)](https://travis-ci.org/mave/mave-ios-sdk)

## Usage

You can see it in action (without any server-side interactions) in the included demo app. To run it:
 - `pod install` to pull the required dependencies
 - then open `MaveSDK.xcworkspace` in xcode and build the `DemoApp` Target.

## Quick Integration

The Mave SDK is available through CocoaPods. To install it, simply add the following line to your Podfile:

```objc
pod "MaveSDK"
```


Then, initialize the SDK in `applicationDidFinishLaunchingWithOptions:`

```objc
#import <MaveSDK.h>;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MaveSDK setupSharedInstance];

    // The rest of your app's setup code
}
```


Then, use the following code to present the page (e.g. in the action for clicking on an "invite friends" button)


```objc
[[MaveSDK sharedInstance] presentInvitePageModallyWithBlock:^(UIViewController *inviteController) {
    // Code to present Mave's view controller from yours, e.g:
    // [self presentViewController:inviteController animated:YES completion:nil];
} dismissBlock:^(UIViewController *controller, NSUInteger numberOfInvitesSent) {
    // Code to transition back to your view controller after Mave's
    // is dismissed (sent invites or cancelled), e.g:
    // [controller dismissViewControllerAnimated:YES completion:nil];
} inviteContext:@"default"];
```


## Author

© Mave Technologies 2015

info@mave.io

## License

MIT. See the LICENSE file.
