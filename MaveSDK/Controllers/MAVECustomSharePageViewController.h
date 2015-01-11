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

// Do the client side shares
- (void)smsClientSideShare;
- (void)emailClientSideShare;
- (void)facebookiOSNativeShare;
- (void)twitteriOSNativeShare;
- (void)clipboardShare;

// Helpers - get copy for the client side shares
// Copy consists of the copy (fetched from server or fallback to default)
//   with the share link appended at the end
- (NSString *)copyForSMSClientSideShare;

// Build a link of the format: http://appjoin.us/<subRoute>/SHARE-TOKEN
+ (NSString *)buildShareLinkWithSubRouteLetter:(NSString *)subRoute
                                    shareToken:(NSString *)shareToken;


@end
