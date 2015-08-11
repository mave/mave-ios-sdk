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
        if (completionBlock) {
            completionBlock(nil, MessageComposeResultFailed);
        }
        return nil;
    }
    MAVESharer *ownInstance = [MAVESharerViewControllerBuilder sharerInstanceRetained];
    ownInstance.completionBlockClientSMS = completionBlock;

    MFMessageComposeViewController *composeVC = [MAVESharerViewControllerBuilder MFMessageComposeViewController];

    composeVC.messageComposeDelegate = ownInstance;
    composeVC.body = ownInstance.remoteConfiguration.clientSMS.text;

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
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeClientSMS shareToken:[[self class] shareToken] audience:nil];
            break;
        }
    }
    if (self.completionBlockClientSMS) {
        self.completionBlockClientSMS(controller, result);
    }
    [self releaseSelf];
}

#pragma mark - client Email

+ (MFMailComposeViewController *)composeClientEmailInviteToRecipientEmails:(NSArray *)recipients withCompletionBlock:(void (^)(MFMailComposeViewController *, MFMailComposeResult))completionBlock {
    if (![MFMailComposeViewController canSendMail]) {
        MAVEErrorLog(@"Tried to do compose client email but canSendMail is false");
        if (completionBlock) {
            completionBlock(nil, MFMailComposeResultFailed);
        }
        return nil;
    }

    MAVESharer *ownInstance = [MAVESharerViewControllerBuilder sharerInstanceRetained];
    ownInstance.completionBlockClientEmail = completionBlock;

    MFMailComposeViewController *composeVC = [MAVESharerViewControllerBuilder MFMailComposeViewController];
    NSString *subject = ownInstance.remoteConfiguration.clientEmail.subject;
    NSString *body = ownInstance.remoteConfiguration.clientEmail.body;

    if ([recipients count] > 0) {
        composeVC.bccRecipients = recipients;
    }
    composeVC.mailComposeDelegate = ownInstance;
    composeVC.subject = subject;
    [composeVC setMessageBody:body isHTML:NO];

    [[MaveSDK sharedInstance].APIInterface trackShareActionClickWithShareType:MAVESharePageShareTypeClientEmail];
    return composeVC;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultSent: {
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeClientEmail shareToken:[[self class] shareToken] audience:nil];
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
    NSString *url = [self shareLinkWithSubRouteLetter:@"f"];

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
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeFacebook shareToken:[[self class] shareToken] audience:nil];
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
    [composeVC setInitialText:ownInstance.remoteConfiguration.twitterShare.text];
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
            [[MaveSDK sharedInstance].APIInterface trackShareWithShareType:MAVESharePageShareTypeTwitter shareToken:[[self class] shareToken] audience:nil];
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
    UIPasteboard *pasteboard = [MAVESharerViewControllerBuilder UIPasteboard];
    pasteboard.string = ownInstance.remoteConfiguration.clipboardShare.text;

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
    [ownInstance releaseSelf];
    return;
}


#pragma mark - Helpers for building share content
- (MAVERemoteConfiguration *)remoteConfiguration {
    return [MaveSDK sharedInstance].remoteConfiguration;
}

+ (NSString *)shareToken {
    MAVEShareToken *tokenObject = [[MaveSDK sharedInstance].shareTokenBuilder createObjectSynchronousWithTimeout:0];
    return tokenObject.shareToken;
}

+ (NSString *)shareCopyFromCopy:(NSString *)shareCopy
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

+ (NSString *)shareLinkBaseURL {
    NSString *inviteLinkDomain = [MaveSDK sharedInstance].remoteConfiguration.customSharePage.inviteLinkBaseURL;
    if (inviteLinkDomain) {
        return [inviteLinkDomain stringByAppendingString:@"/"];
    } else {
        return MAVEShortLinkBaseURL;
    }
}

+ (NSString *)shareLinkWithSubRouteLetter:(NSString *)subRoute {
    MAVEUserData *user = [MaveSDK sharedInstance].userData;
    if (user.inviteLinkDestinationURL && !user.wrapInviteLink) {
        return user.inviteLinkDestinationURL;
    }

    NSString *shareToken = [[self class] shareToken];
    NSString *baseURL = [self shareLinkBaseURL];
    NSString *output;// = MAVEShortLinkBaseURL;

    if ([shareToken length] > 0) {
        NSString *shareToken = [[self class] shareToken];
        output = [NSString stringWithFormat:@"%@%@/%@",
                  baseURL, subRoute, shareToken];
    } else {
        NSString * base64AppID = [MAVEClientPropertyUtils urlSafeBase64ApplicationID];
        output = [NSString stringWithFormat:@"%@o/%@/%@",
                  baseURL, subRoute, base64AppID];
    }
    return output;
}

+ (void)setupShareToken {
    MAVEUserData *user = [MaveSDK sharedInstance].userData;
    // No need to set up if it already exists
    if ([MaveSDK sharedInstance].shareTokenBuilder) {
        return;
    }

    // No need to set up if we're not using Mave links, aka wrapping links
    if (!user.wrapInviteLink) {
        return;
    }

    MAVEDebugLog(@"Setting up share token");
    NSDictionary *linkDetails = [user serializeLinkDetails];
    NSDictionary *storedLinkDetails = nil;

    // try to load stored link details
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *_storedLDData = [userDefaults objectForKey:MAVEUserDefaultsKeyLinkDetails];
    if (_storedLDData) {
        NSError *loadError = nil;
        NSDictionary *tmp = [NSJSONSerialization JSONObjectWithData:_storedLDData options:0 error:&loadError];
        if (loadError) {
            MAVEErrorLog(@"Error reading link details from disk");
        } else {
            storedLinkDetails = tmp;
        }
    }

    // Need a new share token if the link details have changed
    if (![linkDetails isEqualToDictionary:storedLinkDetails]) {
        [MAVEShareToken clearUserDefaults];
    }
    [MaveSDK sharedInstance].shareTokenBuilder = [MAVEShareToken remoteBuilder];

    // serialize & store new link details
    NSError *storeError = nil;
    NSData *_ldData = [NSJSONSerialization dataWithJSONObject:linkDetails options:0 error:&storeError];
    if (storeError) {
        MAVEErrorLog(@"Error serializing link details to JSON to store");
    } else {
        [userDefaults setObject:_ldData forKey:MAVEUserDefaultsKeyLinkDetails];
    }


}

+ (void)resetShareToken {
    MAVEDebugLog(@"Resetting share token after share, was: %@", [[self class] shareToken]);
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
