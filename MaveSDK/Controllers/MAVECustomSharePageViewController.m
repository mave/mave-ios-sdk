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
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }

    // This dismisses the email compose view, so the share page
    // is still active
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)facebookiOSNativeShare {
    // TODO: use the data from the remote config
    // TODO: if they don't have facebook connected in ios we should check if the app has the facebook sdk implemented with the appropriate callbacks.
    SLComposeViewController *facebookSheet = [SLComposeViewController
                                              composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookSheet setInitialText:@"Join me on Swig"];
    [facebookSheet addURL:[NSURL URLWithString:@"http://www.swig.co/"]];
    // TODO: Add completion handler http://stackoverflow.com/questions/13428304/slcomposeviewcontroller-completionhandler
    [self presentViewController:facebookSheet animated:YES completion:nil];
    return;
    
}

- (void)twitteriOSNativeShare {

    // TODO: use the data from the remote config
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:@"Join me http://www.hoteltonight.com/"];
    // TODO: Add completion handler http://stackoverflow.com/questions/13428304/slcomposeviewcontroller-completionhandler
    [self presentViewController:tweetSheet animated:YES completion:nil];
    return;
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
