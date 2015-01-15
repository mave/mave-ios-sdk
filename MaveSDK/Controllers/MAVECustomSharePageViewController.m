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

NSString * const MAVESharePageShareTypeClientSMS = @"client_sms";
NSString * const MAVESharePageShareTypeClientEmail = @"client_email";
NSString * const MAVESharePageShareTypeFacebook = @"facebook";
NSString * const MAVESharePageShareTypeTwitter = @"twitter";
NSString * const MAVESharePageShareTypeClipboard = @"clipboard";


@implementation MAVECustomSharePageViewController

- (void)loadView {
    self.view = [[MAVECustomSharePageView alloc] initWithDelegate:self];
}

- (void)viewDidLoad {
    [[MaveSDK sharedInstance].APIInterface trackInvitePageOpenForPageType:MAVEInvitePageTypeCustomShare];
}

- (void)dismissSelf:(NSUInteger)numberOfInvitesSent {
    // Cleanup for dismiss
    [self.view endEditing:YES];

    // Call dismissal block
    MAVEInvitePageDismissBlock dismissalBlock = [MaveSDK sharedInstance].invitePageDismissBlock;
    if (dismissalBlock) {
        dismissalBlock(self, numberOfInvitesSent);
    }
}

// Call this after a successful share
- (void)dismissAfterShare {
    [self resetShareToken];
    return [self dismissSelf:1];
}

// Call this after a cancel
- (void)dismissAfterCancel {
    return [self dismissSelf:0];
}


- (void)smsClientSideShare {
    MFMessageComposeViewController *controller = [self _createMessageComposeViewController];

    NSString *message = [self shareCopyFromCopy:self.remoteConfiguration.clientSMS.text
                      andLinkWithSubRouteLetter:@"s"];

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
    BOOL dismissSent = NO;

    switch (result) {
        case MessageComposeResultCancelled: {
            break;

        } case MessageComposeResultFailed: {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;

        } case MessageComposeResultSent: {
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeClientSMS shareToken:[self shareToken] audience:nil];
            dismissSent = YES;
            break;

        } default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    if (dismissSent) {
        [self dismissAfterShare];
    }
}

- (void)emailClientSideShare {
    // TODO: use the data from the remote config
    MFMailComposeViewController *mailController = [self _createMailComposeViewController];
    NSString *subject = self.remoteConfiguration.clientEmail.subject;
    NSString *message = [self shareCopyFromCopy:self.remoteConfiguration.clientEmail.body
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
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeClientEmail shareToken:[self shareToken] audience:nil];
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
    NSString *message = self.remoteConfiguration.facebookShare.text;
    NSString *url = [self shareLinkWithSubRouteLetter:@"f"];

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
        [self dismissAfterShare];
    }
}

- (void)twitteriOSNativeShare {
    NSString *message = [self shareCopyFromCopy:self.remoteConfiguration.twitterShare.text
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
        [self dismissAfterShare];
    }
}


- (void)clipboardShare {
    NSString *message = [self shareCopyFromCopy:self.remoteConfiguration.clipboardShare.text
                      andLinkWithSubRouteLetter:@"c"];

    UIPasteboard *pasteboard = [self _generalPasteboardForClipboardShare];
    pasteboard.string = message;

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeClipboard];

    // Any copy to clipboard might be shared, so reset the share token here
    [self resetShareToken];

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


#pragma mark - Helpers for building share content

- (MAVERemoteConfiguration *)remoteConfiguration {
    return [MaveSDK sharedInstance].remoteConfiguration;
}

- (NSString *)shareToken {
    MAVEShareToken *tokenObject = [[MaveSDK sharedInstance].shareTokenBuilder createObjectSynchronousWithTimeout:0];
    return tokenObject.shareToken;
}

- (NSString *)shareCopyFromCopy:(NSString *)shareCopy
      andLinkWithSubRouteLetter:(NSString *)letter {
    NSString* link = [self shareLinkWithSubRouteLetter:letter];
    NSString *outputText = shareCopy;
    if ([outputText length] == 0) {
        outputText = link;
    } else {
        // if string doesn't end in a whitespace char, append a regular space
        NSString *lastLetter = [outputText substringFromIndex:([outputText length] - 1)];
        if (![@[@" ", @"\n"] containsObject:lastLetter]) {
            outputText = [outputText stringByAppendingString:@" "];
        }
        outputText = [outputText stringByAppendingString:link];
    }
    return outputText;
}

- (NSString *)shareLinkWithSubRouteLetter:(NSString *)subRoute {
    NSString *shareToken = [self shareToken];
    NSString *output;// = MAVEShortLinkBaseURL;

    if ([shareToken length] > 0) {
        NSString *shareToken = [self shareToken];
        output = [NSString stringWithFormat:@"%@%@/%@",
                  MAVEShortLinkBaseURL, subRoute, shareToken];
    } else {
        NSString * base64AppID = [MAVEClientPropertyUtils urlSafeBase64ApplicationID];
        output = [NSString stringWithFormat:@"%@o/%@/%@",
                  MAVEShortLinkBaseURL, subRoute, base64AppID];
    }
    return output;
}

- (void)resetShareToken {
    MAVEDebugLog(@"Resetting share token after share, was: %@", [self shareToken]);
    [MAVEShareToken clearUserDefaults];
    [MaveSDK sharedInstance].shareTokenBuilder = [MAVEShareToken remoteBuilder];
}


@end
