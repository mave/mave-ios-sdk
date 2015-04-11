//
//  MAVESharer.h
//  MaveSDK
//
//  Created by Danny Cosson on 3/6/15.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "MAVERemoteConfiguration.h"

extern NSString * const MAVESharePageShareTypeClientSMS;
extern NSString * const MAVESharePageShareTypeClientEmail;
extern NSString * const MAVESharePageShareTypeFacebook;
extern NSString * const MAVESharePageShareTypeTwitter;
extern NSString * const MAVESharePageShareTypeClipboard;

@interface MAVESharer : NSObject <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) MAVESharer *retainedSelf;
@property (nonatomic, strong) void(^completionBlockClientSMS)(MFMessageComposeViewController *controller, MessageComposeResult composeResult);
@property (nonatomic, strong) void(^completionBlockClientEmail)(MFMailComposeViewController *controller, MFMailComposeResult result);
@property (nonatomic, strong) void(^completionBlockFacebookNativeShare)(SLComposeViewController *controller, SLComposeViewControllerResult result);
@property (nonatomic, strong) void(^completionBlockTwitterNativeShare)(SLComposeViewController *controller, SLComposeViewControllerResult result);

- (instancetype)initAndRetainSelf;
- (void)releaseSelf;

//
// Methods to compose and share, they return UIViewControllers that need to be presented to display the compose views
//
+ (MFMessageComposeViewController *)composeClientSMSInviteToRecipientPhones:(NSArray *)recipientPhones completionBlock:(void(^)(MFMessageComposeViewController *controller, MessageComposeResult composeResult))completionBlock;
+ (MFMailComposeViewController *)composeClientEmailWithCompletionBlock:(void(^)(MFMailComposeViewController *controller, MFMailComposeResult result))completionBlock;
+ (SLComposeViewController *)composeFacebookNativeShareWithCompletionBlock:(void(^)(SLComposeViewController *controller, SLComposeViewControllerResult result)) completionBlock;
+ (SLComposeViewController *)composeTwitterNativeShareWithCompletionBlock:(void(^)(SLComposeViewController *controller, SLComposeViewControllerResult result)) completionBlock;
+ (void)composePasteboardShare;

// Extra completion methods
- (void)facebookNativeShareController:(SLComposeViewController *)controller didFinishWithResult:(SLComposeViewControllerResult)result;
- (void)twitterNativeShareController:(SLComposeViewController *)controller didFinishWithResult:(SLComposeViewControllerResult)result;

//
// Helpers
//
- (MAVERemoteConfiguration *)remoteConfiguration;
+ (NSString *)shareToken;
+ (NSString *)shareCopyFromCopy:(NSString *)shareCopy
      andLinkWithSubRouteLetter:(NSString *)letter;
// Build a link of the format: http://appjoin.us/<subRoute>/SHARE-TOKEN
+ (NSString *)shareLinkWithSubRouteLetter:(NSString *)subRoute;
+ (void)resetShareToken;

@end


@interface MAVESharerViewControllerBuilder : NSObject

+ (MAVESharer *)sharerInstanceRetained;
+ (MFMessageComposeViewController *)MFMessageComposeViewController;
+ (MFMailComposeViewController *)MFMailComposeViewController;
+ (SLComposeViewController *)SLComposeViewControllerForFacebook;
+ (SLComposeViewController *)SLComposeViewControllerForTwitter;
+ (UIPasteboard *)UIPasteboard;

@end
