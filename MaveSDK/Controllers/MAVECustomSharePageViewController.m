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
#import "MAVEConstants.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVECustomSharePageView.h"
#import "MAVERemoteConfiguration.h"
#import "MAVEShareToken.h"

NSString * const MAVESharePageShareTypeClientSMS = @"client_sms";
NSString * const MAVESharePageShareTypeClientEmail = @"client_email";
NSString * const MAVESharePageShareTypeFacebook = @"facebook";
NSString * const MAVESharePageShareTypeTwitter = @"twitter";


@implementation MAVECustomSharePageViewController

- (void)loadView {
    self.view = [[MAVECustomSharePageView alloc] initWithDelegate:self];
}

- (void)viewDidLoad {
    [[MaveSDK sharedInstance].invitePageChooser
     setupNavigationBar:self
     leftBarButtonTarget:self
     leftBarButtonAction:@selector(dismissAfterCancel)];

    [[MaveSDK sharedInstance].APIInterface trackInvitePageOpenForPageType:MAVEInvitePageTypeCustomShare];
}

- (void)dismissSelf:(NSUInteger)numberOfInvitesSent {
    // Cleanup for dismiss
    [self.view endEditing:YES];

    // Call dismissal block
    MAVEInvitePageDismissBlock dismissalBlock = [MaveSDK sharedInstance].invitePageDismissalBlock;
    if (dismissalBlock) {
        dismissalBlock(self, numberOfInvitesSent);
    }
}

- (void)dismissAfterCancel {
    return [self dismissSelf:0];
}


- (void)smsClientSideShare {
    MFMessageComposeViewController *controller = [self _createMessageComposeViewController];

    NSString *message = [self.remoteConfiguration.clientSMS.text stringByAppendingString:[self shareLinkWithSubRouteLetter:@"s"]];

    controller.messageComposeDelegate = self;
    controller.body = message;

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeClientSMS];
    
    // Present message view controller on screen
    [self presentViewController:controller animated:YES completion:nil];
}
// This method can easily be mocked when we can't create a real
// one of these controllers
- (MFMessageComposeViewController *)_createMessageComposeViewController {
    return [[MFMessageComposeViewController alloc] init];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult) result
{
    BOOL dismissSentOneSMS = NO;

    switch (result) {
        case MessageComposeResultCancelled: {
            break;

        } case MessageComposeResultFailed: {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;

        } case MessageComposeResultSent: {
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeClientSMS shareToken:[self shareToken] audience:nil];
            dismissSentOneSMS = YES;
            break;

        } default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    if (dismissSentOneSMS ) {
        [self dismissSelf:1];
    }
}

- (void)emailClientSideShare {
    // TODO: use the data from the remote config
    MFMailComposeViewController *mailController = [self _createMailComposeViewController];
    NSString *subject = self.remoteConfiguration.clientEmail.subject;
    NSString *message = [self.remoteConfiguration.clientEmail.body stringByAppendingString:[self shareLinkWithSubRouteLetter:@"s"]];

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
    BOOL dismissSentOneEmail = NO;

    switch (result) {
        case MFMailComposeResultSent:
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeClientEmail shareToken:[self shareToken] audience:nil];
            dismissSentOneEmail = YES;
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
    if (dismissSentOneEmail) {
        [self dismissSelf:1];
    }
}

- (void)facebookiOSNativeShare {
    // TODO: if they don't have facebook connected in ios we should check if the app has the facebook sdk implemented with the appropriate callbacks.
    NSString *message = self.remoteConfiguration.facebookShare.text;
    NSString *url = [self shareLinkWithSubRouteLetter:@"s"];

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
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeFacebook shareToken:[self shareToken] audience:nil];
            dismissShared = YES;
        } case SLComposeViewControllerResultCancelled: {
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if (dismissShared) {
        [self dismissSelf:1];
    }
}

- (void)twitteriOSNativeShare {
    NSString *message = [self.remoteConfiguration.twitterShare.text stringByAppendingString:[self shareLinkWithSubRouteLetter:@"t"]];

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
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeTwitter shareToken:[self shareToken] audience:nil];
            dismissShared = YES;
        } case SLComposeViewControllerResultCancelled: {
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if (dismissShared) {
        [self dismissSelf:1];
    }
}


- (void)clipboardShare {
    
    // Copy to clipboard
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    // TODO: use the data from the remote config
    pasteboard.string = @"Join me on Swig";
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


#pragma mark - Helpers for building share content

- (MAVERemoteConfiguration *)remoteConfiguration {
    MAVERemoteConfiguration *config = [[MaveSDK sharedInstance].remoteConfigurationBuilder createObjectSynchronousWithTimeout:0];
    return config;
}

- (NSString *)shareToken {
    MAVEShareToken *tokenObject = [[MaveSDK sharedInstance].shareTokenBuilder createObjectSynchronousWithTimeout:0];
    return tokenObject.shareToken;
}

- (NSString *)shareLinkWithSubRouteLetter:(NSString *)subRoute {
    NSString *shareToken = [self shareToken];
    NSString *output = MAVEShortLinkBaseURL;
    output = [output stringByAppendingString:subRoute];
    output = [output stringByAppendingString:@"/"];
    output = [output stringByAppendingString:shareToken];
    return output;
}


@end
