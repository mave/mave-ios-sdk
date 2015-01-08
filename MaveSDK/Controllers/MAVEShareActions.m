//
//  MAVEShareActions.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "MaveSDK.h"
#import "MAVEShareActions.h"


@implementation MAVEShareActions

- (void)facebookiOSNativeShare {
    NSLog(@"facebook share");
    // if they don't have facebook connected in ios we should check if the app has the facebook sdk implemented with the appropriate callbacks.
    SLComposeViewController *facebookSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookSheet setInitialText:@"Join me"];
    [self presentViewController:facebookSheet animated:YES completion:nil];
    return;

}

- (void)smsClientSideShare {
    
    NSLog(@"sent local sms");
}

- (void)twitteriOSNativeShare {
    NSLog(@"twitter share %@", [MaveSDK sharedInstance].viewController);
    
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:@"Join me"];
    [[MaveSDK sharedInstance].viewController presentViewController:tweetSheet animated:YES completion:nil];
    return;
}

@end
