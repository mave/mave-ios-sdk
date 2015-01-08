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
#import "MAVECustomSharePageView.h"


@implementation MAVEShareActions

- (void)loadView {
    self.view = [[MAVECustomSharePageView alloc] init];
}

+ (UIViewController *)rootViewController {
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    return window.rootViewController;
}

- (void)facebookiOSNativeShare {
    // TODO: use the data from the remote config
    // TODO: if they don't have facebook connected in ios we should check if the app has the facebook sdk implemented with the appropriate callbacks.
    SLComposeViewController *facebookSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookSheet setInitialText:@"Join me on Swig"];
    [facebookSheet addURL:[NSURL URLWithString:@"http://www.swig.co/"]];
    [self presentViewController:facebookSheet animated:YES completion:nil];
    return;

}

- (void)smsClientSideShare {
    
    NSLog(@"sent local sms");
}

- (void)emailClientSideShare {
    
    NSLog(@"sent local sms");
}


- (void)twitteriOSNativeShare {

    // TODO: use the data from the remote config
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:@"Join me"];
    [tweetSheet addURL:[NSURL URLWithString:@"http://www.swig.co/"]];
    [self presentViewController:tweetSheet animated:YES completion:nil];
    return;
}

@end
