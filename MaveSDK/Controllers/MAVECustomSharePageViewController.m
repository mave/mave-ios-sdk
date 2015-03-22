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
    // TODO: use the data from the remote config
    MFMailComposeViewController *mailController = [self _createMailComposeViewController];
    NSString *subject = self.sharerObject.remoteConfiguration.clientEmail.subject;
    NSString *message = [self.sharerObject shareCopyFromCopy:self.sharerObject.remoteConfiguration.clientEmail.body
                      andLinkWithSubRouteLetter:@"e"];

    mailController.mailComposeDelegate = self;
    mailController.subject = subject;
    [mailController setMessageBody:message isHTML:NO];

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeClientEmail];
    
    [self presentViewController:mailController animated:YES completion:nil];
}
- (MFMailComposeViewController *)_createMailComposeViewController {
    return [[MFMailComposeViewController alloc] init];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    BOOL dismissSent = NO;

    switch (result) {
        case MFMailComposeResultSent:
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeClientEmail shareToken:[self.sharerObject shareToken] audience:nil];
            dismissSent = YES;
            break;

        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }

    // This dismisses the email compose view, so the share page
    // is still active
    [self dismissViewControllerAnimated:YES completion:nil];
    if (dismissSent) {
        [self dismissAfterShare];
    }
}

- (void)facebookiOSNativeShare {
    // TODO: if they don't have facebook connected in ios we should check if the app has the facebook sdk implemented with the appropriate callbacks.
    NSString *message = self.sharerObject.remoteConfiguration.facebookShare.text;
    NSString *url = [self.sharerObject shareLinkWithSubRouteLetter:@"f"];

    SLComposeViewController *facebookSheet = [self _createFacebookComposeViewController];
    [facebookSheet setInitialText:message];
    [facebookSheet addURL:[NSURL URLWithString:url]];
    facebookSheet.completionHandler = ^(SLComposeViewControllerResult result){
        [self facebookHandleShareResult:result];
    };

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeFacebook];
    [self presentViewController:facebookSheet animated:YES completion:nil];
    return;
}
- (SLComposeViewController *)_createFacebookComposeViewController {
    return [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
}

- (void)facebookHandleShareResult:(SLComposeViewControllerResult) result {
    BOOL dismissShared = NO;
    switch (result) {
        case SLComposeViewControllerResultDone: {
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeFacebook shareToken:[self.sharerObject shareToken] audience:nil];
            dismissShared = YES;
        } case SLComposeViewControllerResultCancelled: {
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if (dismissShared) {
        [self dismissAfterShare];
    }
}

- (void)twitteriOSNativeShare {
    NSString *message = [self.sharerObject shareCopyFromCopy:self.sharerObject.remoteConfiguration.twitterShare.text
                      andLinkWithSubRouteLetter:@"t"];

    SLComposeViewController *tweetSheet = [self _createTwitterComposeViewController];
    [tweetSheet setInitialText:message];
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        [self twitterHandleShareResult:result];
    };
    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeTwitter];

    [self presentViewController:tweetSheet animated:YES completion:nil];
}
- (SLComposeViewController *)_createTwitterComposeViewController {
    return [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
}

- (void)twitterHandleShareResult:(SLComposeViewControllerResult) result {
    BOOL dismissShared = NO;
    switch (result) {
        case SLComposeViewControllerResultDone: {
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeTwitter shareToken:[self.sharerObject shareToken] audience:nil];
            dismissShared = YES;
        } case SLComposeViewControllerResultCancelled: {
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if (dismissShared) {
        [self dismissAfterShare];
    }
}


- (void)clipboardShare {
    NSString *message = [self.sharerObject shareCopyFromCopy:self.sharerObject.remoteConfiguration.clipboardShare.text
                      andLinkWithSubRouteLetter:@"c"];

    UIPasteboard *pasteboard = [self _generalPasteboardForClipboardShare];
    pasteboard.string = message;

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeClipboard];

    // Any copy to clipboard might be shared, so reset the share token here
    [self.sharerObject resetShareToken];

    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"✔ Copied Link"
                                        message:nil
                                      delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:nil];
    [alert show];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
    return;
}
- (UIPasteboard *)_generalPasteboardForClipboardShare {
    return [UIPasteboard generalPasteboard];
}

@end
