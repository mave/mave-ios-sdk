//
//  MAVEShareActions.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface MAVEShareActions: UIViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> 

- (void)smsClientSideShare;
- (void)emailClientSideShare;
- (void)facebookiOSNativeShare;
- (void)twitteriOSNativeShare;
- (void)clipboardShare;

@end
