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
- (void)dismissSelf:(NSUInteger)numberOfInvitesSent;

// Do the client side shares
- (void)smsClientSideShare;
- (void)emailClientSideShare;
- (void)facebookiOSNativeShare;
- (void)twitteriOSNativeShare;
- (void)clipboardShare;

// Helpers

- (NSString *)shareToken;

// Build a link of the format: http://appjoin.us/<subRoute>/SHARE-TOKEN
+ (NSString *)buildShareLinkWithSubRouteLetter:(NSString *)subRoute
                                    shareToken:(NSString *)shareToken;


@end
