//
//  MAVEShareActions.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "MAVERemoteConfiguration.h"

@interface MAVECustomSharePageViewController: UIViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

- (void)dismissAfterCancel;
- (void)dismissSelf:(NSUInteger)numberOfInvitesSent;

// Do the client side shares
- (void)smsClientSideShare;
// this is a helper to let us test in the simulater where we can't init the
// message compose controller
- (MFMessageComposeViewController *)_createMessageComposeViewController;
- (void)emailClientSideShare;
- (void)facebookiOSNativeShare;
- (void)twitteriOSNativeShare;
- (void)clipboardShare;

// Helpers

- (MAVERemoteConfiguration *)remoteConfiguration;
- (NSString *)shareToken;
// Build a link of the format: http://appjoin.us/<subRoute>/SHARE-TOKEN
- (NSString *)shareLinkWithSubRouteLetter:(NSString *)subRoute;


@end
