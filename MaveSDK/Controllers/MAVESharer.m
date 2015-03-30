//
//  MAVESharer.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/6/15.
//
//

#import "MAVESharer.h"
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVERemoteConfiguration.h"
#import "MaveShareToken.h"
#import "MAVEClientPropertyUtils.h"

NSString * const MAVESharePageShareTypeClientSMS = @"client_sms";
NSString * const MAVESharePageShareTypeClientEmail = @"client_email";
NSString * const MAVESharePageShareTypeFacebook = @"facebook";
NSString * const MAVESharePageShareTypeTwitter = @"twitter";
NSString * const MAVESharePageShareTypeClipboard = @"clipboard";

@implementation MAVESharer

- (instancetype)initAndRetainSelf {
    if (self = [super init]) {
        self.retainedSelf = self;
    }
    return self;
}

- (void)releaseSelf {
    self.completionBlockClientSMS = nil;
    self.completionBlockClientEmail = nil;
    self.retainedSelf = nil;
}

#pragma mark - client SMS

+ (MFMessageComposeViewController *)composeClientSMSInviteToRecipientPhones:(NSArray *)recipientPhones completionBlock:(void (^)(MFMessageComposeViewController *controller, MessageComposeResult composeResult))completionBlock {
    if (![MFMessageComposeViewController canSendText]) {
        MAVEErrorLog(@"Tried to do compose client sms but canSendText is false");
        return nil;
    }
    MAVESharer *ownInstance = [MAVESharerViewControllerBuilder sharerInstanceRetained];
    ownInstance.completionBlockClientSMS = completionBlock;

    MFMessageComposeViewController *composeVC = [MAVESharerViewControllerBuilder MFMessageComposeViewController];
    MAVEUserData *maveUser = [MaveSDK sharedInstance].userData;
    NSString *message;
    if ( maveUser.inviteLinkDestinationURL && !maveUser.wrapInviteLink ) {
        // If the inviteLinkDestinationURL is set, and the link should NOT be wrapped, pass the raw inviteLinkDestinationURL to the SMS VC
        message = [[ownInstance.remoteConfiguration.clientSMS.text stringByAppendingString:@" "] stringByAppendingString:maveUser.inviteLinkDestinationURL];
    } else {
        message = [ownInstance shareCopyFromCopy:ownInstance.remoteConfiguration.clientSMS.text andLinkWithSubRouteLetter:@"s"];
    }

    composeVC.messageComposeDelegate = ownInstance;
    composeVC.body = message;

    if (recipientPhones && [recipientPhones count] > 0) {
        composeVC.recipients = recipientPhones;
    }

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeClientSMS];
    return composeVC;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled: {
            break;
        }
        case MessageComposeResultFailed: {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
        }
        case MessageComposeResultSent: {
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeClientSMS shareToken:[self shareToken] audience:nil];
            break;
        }
    }
    if (self.completionBlockClientSMS) {
        self.completionBlockClientSMS(controller, result);
    }
    [self releaseSelf];
}

#pragma mark - client Email

+ (MFMailComposeViewController *)composeClientEmailWithCompletionBlock:(void (^)(MFMailComposeViewController *, MFMailComposeResult))completionBlock {

    MAVESharer *ownInstance = [MAVESharerViewControllerBuilder sharerInstanceRetained];
    ownInstance.completionBlockClientEmail = completionBlock;

    MFMailComposeViewController *composeVC = [MAVESharerViewControllerBuilder MFMailComposeViewController];
    NSString *subject = ownInstance.remoteConfiguration.clientEmail.subject;
    NSString *message = [ownInstance shareCopyFromCopy:ownInstance.remoteConfiguration.clientEmail.body
                                   andLinkWithSubRouteLetter:@"e"];

    composeVC.mailComposeDelegate = ownInstance;
    composeVC.subject = subject;
    [composeVC setMessageBody:message isHTML:NO];

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeClientEmail];
    return composeVC;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultSent: {
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeClientEmail shareToken:[self shareToken] audience:nil];
            break;
        }
        case MFMailComposeResultFailed: {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send Email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MFMailComposeResultSaved: {
            break;
        }
        case MFMailComposeResultCancelled: {
            break;
        }
    }
    if (self.completionBlockClientEmail) {
        self.completionBlockClientEmail(controller, result);
    }
    [self releaseSelf];
}

+ (SLComposeViewController *)composeFacebookNativeShareWithCompletionBlock:(void (^)(SLComposeViewController *, SLComposeViewControllerResult))completionBlock {

    MAVESharer *ownInstance = [MAVESharerViewControllerBuilder sharerInstanceRetained];
    ownInstance.completionBlockFacebookNativeShare = completionBlock;

    SLComposeViewController *composeVC = [MAVESharerViewControllerBuilder SLComposeViewControllerForFacebook];
    NSString *message = ownInstance.remoteConfiguration.facebookShare.text;
    NSString *url = [ownInstance shareLinkWithSubRouteLetter:@"f"];

    [composeVC setInitialText:message];
    [composeVC addURL:[NSURL URLWithString:url]];
    __weak SLComposeViewController *weakComposeVC = composeVC;
    composeVC.completionHandler = ^(SLComposeViewControllerResult result){
        [ownInstance facebookNativeShareController:weakComposeVC didFinishWithResult:result];
    };

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeFacebook];
    return composeVC;
}

- (void)facebookNativeShareController:(SLComposeViewController *)controller didFinishWithResult:(SLComposeViewControllerResult)result {
    switch (result) {
        case SLComposeViewControllerResultDone: {
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeFacebook shareToken:[self shareToken] audience:nil];
        } case SLComposeViewControllerResultCancelled: {
            break;
        }
        default:
            break;
    }

    if (self.completionBlockFacebookNativeShare) {
        self.completionBlockFacebookNativeShare(controller, result);
    }
    self.completionBlockFacebookNativeShare = nil;
    [self releaseSelf];
}

+ (SLComposeViewController *)composeTwitterNativeShareWithCompletionBlock:(void (^)(SLComposeViewController *, SLComposeViewControllerResult))completionBlock {

    MAVESharer *ownInstance = [MAVESharerViewControllerBuilder sharerInstanceRetained];
    ownInstance.completionBlockTwitterNativeShare = completionBlock;

    SLComposeViewController *composeVC = [MAVESharerViewControllerBuilder SLComposeViewControllerForTwitter];
    NSString *message = [ownInstance shareCopyFromCopy:ownInstance.remoteConfiguration.twitterShare.text
                                   andLinkWithSubRouteLetter:@"t"];
    [composeVC setInitialText:message];
    __weak SLComposeViewController *weakComposeVC = composeVC;
    composeVC.completionHandler = ^(SLComposeViewControllerResult result) {
        [ownInstance twitterNativeShareController:weakComposeVC didFinishWithResult:result];
    };

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeTwitter];
    return composeVC;
}

- (void)twitterNativeShareController:(SLComposeViewController *)controller didFinishWithResult:(SLComposeViewControllerResult)result {
    switch (result) {
        case SLComposeViewControllerResultDone: {
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeTwitter shareToken:[self shareToken] audience:nil];
        } case SLComposeViewControllerResultCancelled: {
            break;
        }
    }
    if (self.completionBlockTwitterNativeShare) {
        self.completionBlockTwitterNativeShare(controller, result);
    }
    self.completionBlockTwitterNativeShare = nil;
    [self releaseSelf];
}

+ (void)composePasteboardShare {
    MAVESharer *ownInstance = [MAVESharerViewControllerBuilder sharerInstanceRetained];
    NSString *message = [ownInstance shareCopyFromCopy:ownInstance.remoteConfiguration.clipboardShare.text
                                   andLinkWithSubRouteLetter:@"c"];

    UIPasteboard *pasteboard = [MAVESharerViewControllerBuilder UIPasteboard];
    pasteboard.string = message;

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeClipboard];

    // Any copy to clipboard might be shared, so reset the share token here
    [ownInstance resetShareToken];

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
    [ownInstance releaseSelf];
    return;
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


// Builder to allow mocking for testing, it just returns the different types
// of share view controllers we'll need to present after calling alloc init
@implementation MAVESharerViewControllerBuilder

+ (MAVESharer *)sharerInstanceRetained {
    return [[MAVESharer alloc] initAndRetainSelf];
}
+ (MFMessageComposeViewController *)MFMessageComposeViewController {
    return [[MFMessageComposeViewController alloc] init];
}
+ (MFMailComposeViewController *)MFMailComposeViewController {
    return [[MFMailComposeViewController alloc] init];
}

+ (SLComposeViewController *)SLComposeViewControllerForFacebook {
    return [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
}

+ (SLComposeViewController *)SLComposeViewControllerForTwitter {
    return [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
}

+ (UIPasteboard *)UIPasteboard {
    return [UIPasteboard generalPasteboard];
}

@end
