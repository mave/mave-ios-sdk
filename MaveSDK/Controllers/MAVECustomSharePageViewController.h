//
//  MAVEShareActions.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "MAVERemoteConfiguration.h"

@interface MAVECustomSharePageViewController: UIViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

- (void)dismissAfterShare;

// Do the client side shares
// the helpers let us test in the simulator
- (void)smsClientSideShare;
// this is a helper to let us test in the simulater where we can't init the
// message compose controller
- (MFMessageComposeViewController *)_createMessageComposeViewController;
- (void)emailClientSideShare;
- (MFMailComposeViewController *)_createMailComposeViewController;
- (void)facebookiOSNativeShare;
- (SLComposeViewController *)_createFacebookComposeViewController;
- (void)facebookHandleShareResult:(SLComposeViewControllerResult) result;
- (void)twitteriOSNativeShare;
- (SLComposeViewController *)_createTwitterComposeViewController;
- (void)twitterHandleShareResult:(SLComposeViewControllerResult) result;
- (void)clipboardShare;
- (UIPasteboard *)_generalPasteboardForClipboardShare;

// Helpers

- (MAVERemoteConfiguration *)remoteConfiguration;
- (NSString *)shareToken;
- (NSString *)shareCopyFromCopy:(NSString *)shareCopy
      andLinkWithSubRouteLetter:(NSString *)letter;
// Build a link of the format: http://appjoin.us/<subRoute>/SHARE-TOKEN
- (NSString *)shareLinkWithSubRouteLetter:(NSString *)subRoute;
- (void)resetShareToken;


@end
