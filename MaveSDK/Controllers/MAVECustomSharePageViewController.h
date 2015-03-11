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
#import "MAVESharer.h"

@interface MAVECustomSharePageViewController: UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) MAVESharer *sharerObject;

- (void)dismissAfterShare;

- (void)smsClientSideShare;

// Do the client side shares
// the helpers let us test in the simulator
// TODO: move these all the MAVESharer object so we can re-use them on different
// view controllers
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

@end
