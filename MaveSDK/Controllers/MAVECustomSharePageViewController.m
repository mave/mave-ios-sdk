//
//  MAVEShareActions.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "MaveSDK.h"
#import "MaveSDK_Internal.h"
#import "MAVEConstants.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVECustomSharePageView.h"
#import "MAVERemoteConfiguration.h"
#import "MAVEShareToken.h"
#import "MAVEClientPropertyUtils.h"


@implementation MAVECustomSharePageViewController

- (void)loadView {
    self.view = [[MAVECustomSharePageView alloc] initWithDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sharerObject = [[MAVESharer alloc] init];
    [[MaveSDK sharedInstance].APIInterface trackInvitePageOpenForPageType:MAVEInvitePageTypeCustomShare];
}

// Call this after a successful share
- (void)dismissAfterShare {
    [self.sharerObject resetShareToken];
    return [[MaveSDK sharedInstance].invitePageChooser dismissOnSuccess:1];
}

- (void)smsClientSideShare {
    UIViewController *vc = [MAVESharer composeClientSMSInviteToRecipientPhones:nil completionBlock:^(MFMessageComposeViewController *controller, MessageComposeResult result) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (result == MessageComposeResultSent) {
            [self dismissAfterShare];
        }
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)emailClientSideShare {
    UIViewController *vc = [MAVESharer composeClientEmailWithCompletionBlock:^(MFMailComposeViewController *controller, MFMailComposeResult result) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (result == MFMailComposeResultSent) {
            [self dismissAfterShare];
        }
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)facebookiOSNativeShare {
    UIViewController *vc = [MAVESharer composeFacebookNativeShareWithCompletionBlock:^(SLComposeViewController *controller, SLComposeViewControllerResult result) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (result == SLComposeViewControllerResultDone) {
            [self dismissAfterShare];
        }
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)twitteriOSNativeShare {
    UIViewController *vc = [MAVESharer composeTwitterNativeShareWithCompletionBlock:^(SLComposeViewController *controller, SLComposeViewControllerResult result) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (result == SLComposeViewControllerResultDone) {
            [self dismissAfterShare];
        }
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)clipboardShare {
    [MAVESharer composePasteboardShare];
}

@end
