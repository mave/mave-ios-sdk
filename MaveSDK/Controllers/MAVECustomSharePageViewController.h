//
//  MAVEShareActions.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface MAVECustomSharePageViewController: UIViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

- (void)dismissAfterCancel;

- (void)smsClientSideShare;
- (void)emailClientSideShare;
- (void)facebookiOSNativeShare;
- (void)twitteriOSNativeShare;
- (void)clipboardShare;

@end
