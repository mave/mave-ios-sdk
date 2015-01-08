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

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)smsClientSideShare {

    //TODO: test this on a phone, can't test on a simulator
    NSString *message = [NSString stringWithFormat:@"Join me on Swig http://swig.co"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];

    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    NSLog(@"sent local sms");
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
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
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)emailClientSideShare {
    // TODO: use the data from the remote config
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:@"Join Swig"];
    [mailController setMessageBody:@"Get wit it" isHTML:NO];
    
    [self presentViewController:mailController animated:YES completion:NULL];
    return;
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

- (void)twitteriOSNativeShare {

    // TODO: use the data from the remote config
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:@"Join me http://www.hoteltonight.com/"];
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
                                        message:nil delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles: nil];
    
    [alert show];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alert dismissWithClickedButtonIndex:0 animated:YES];

    });
    return;
}


@end
