//
//  InvitePage.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAVEInvitePageViewController.h"
#import "MAVEDisplayOptions.h"
#import "MAVEUserData.h"
#import "MAVEReferringData.h"
#import "MAVEInvitePageChooser.h"
#import "MAVEAPIInterface.h"
#import "MAVERemoteObjectBuilder.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVEABSyncManager.h"

@interface MaveSDK : NSObject

@property (nonatomic, strong) MAVEDisplayOptions *displayOptions;
@property (nonatomic, copy) NSString *defaultSMSMessageText;
@property (nonatomic, strong) MAVEAPIInterface *APIInterface;
@property (nonatomic, strong) MAVEABSyncManager *addressBookSyncManager;
@property (nonatomic, strong) MAVEInvitePageChooser *invitePageChooser;
@property (nonatomic, strong) MAVERemoteObjectBuilder *remoteConfigurationBuilder;
@property (nonatomic, strong) MAVERemoteObjectBuilder *shareTokenBuilder;
@property (nonatomic, strong) MAVERemoteObjectBuilder *suggestedInvitesBuilder;
@property (nonatomic, strong) MAVERemoteObjectBuilder *referringDataBuilder;


@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appDeviceID;
@property (nonatomic, assign) BOOL isInitialAppLaunch;
@property (nonatomic, copy) NSString *inviteContext;
@property (nonatomic, strong) MAVEUserData *userData;

+ (void)setupSharedInstanceWithApplicationID:(NSString *)applicationID;
+ (instancetype)sharedInstance;

// Internal, method to access the remote configuration
- (MAVERemoteConfiguration *)remoteConfiguration;
- (NSArray *)suggestedInvitesWithFullContactsList:(NSArray *)contacts delay:(CGFloat)seconds;

- (BOOL)isSetupOK;

- (void)getReferringData:(void(^)(MAVEReferringData *referringData))referringDataHandler;

// Use this to identify your logged-in users to us
- (void)identifyUser:(MAVEUserData *)userData;
// Use anonymous users if you don't have user accounts. Mave will generate
// a user id to match this device in the future and try to get the user's name
// from the device info. If we can't get the user's name
- (void)identifyAnonymousUser;

- (void)trackSignup;

// Present the view controller modally (or in a drawer, etc.)
//
// @presentBlock - block for you to present the Mave invite view controller from your app
// @dismissBlock - block to transition back to your app after user sends invites or cancels.
//                 It gets a "number of invites sent" parameter if you need to tell whether
//                   the user sent any invites/shared or not.
// @inviteContext - a string to identify where the invite page was presented from. If you are
//                  displaying the invite page from multiple places in your app (e.g. from the
//                  menu and in the signup flow) this is important for tracking because you
//                  typically expect the page to perform differently depending on where it's
//                  presented from.
- (void)presentInvitePageModallyWithBlock:(MAVEInvitePagePresentBlock)presentBlock
                             dismissBlock:(MAVEInvitePageDismissBlock)dismissBlock
                            inviteContext:(NSString*)inviteContext;

// Present the invite page by pushing onto an existing navigation controller stack
// Otherwise it's the same as previous method.
- (void)presentInvitePagePushWithBlock:(MAVEInvitePagePresentBlock)presentBlock
                             forwardBlock:(MAVEInvitePageDismissBlock)forwardBlock
                             backBlock:(MAVEInvitePageDismissBlock)backBlock
                         inviteContext:(NSString *)inviteContext;

// Send SMS invite messages programatically
//
// The messge sent will be in the format:
//   <sender first name>[ <last name>]: <message> <invite link>
//
// Sender first name & last name come from the user data, which you set with the
// `identifyUser` call. Message is the message passed in here, and invite link
// will be a Mave wrapped link attached to the invite.
//
// Args:
//
// - message is the message to send in the invite
//
// - recipientPhoneNumbers is an array of phone numbers to send invites too. The
//       phone numbers can be in e.164 format (begin with +country code) or just
//       10-digit U.S. phone numbers begginning with area code. We only support
//       sending SMS messages to the U.S. for now.
//       Any phone numbers in incorrect format will be silenty skipped.
//
// - additionalOptions is a dictionary of optional parameters, use nil if none.
//     Available options are:
//     - "invite_context" - this is a string you can use if you are sending invites
//           in different places (contexts) in your app to be able to look at the
//           stats separately. Some examples might be "after first purchase" or
//           "signup flow". Defaults to "programatic invite" if not set.
//     - "link_destination_url" - you can optionally pass in a URL to which the link
//           in the invite will redirect. If not set we use the app store link, you
//           only need to set this if you want each invite to go to a different URL.
//     - "custom_referring_data" - this is a freeform dictionary that you can use to
//           pass through any data you want to retrieve once the invited user opens
//           your app from this invite link. It will be available as the `customData`
//           property on the MAVEReferringData object. It is sent over our API as JSON
//           data so the object you pass in here must be JSON serializable - i.e.
//           NSJSONSerializiation `isValidJSONObject:` returns true.
//
//
// - errorBlock is a block that will be called with an error if you want to be notified
//       if invites fail to send. This could happen if the parameters are not passed in
//       or set up correctly, if the device can't reach our servers, etc.
//       Note that the absense of an error does not guarantee the invites were delivered
//       successfully (phone number could have gone out of service, etc. but these
//       kinds of errors should be relatively uncommon).
- (void)sendSMSInviteMessage:(NSString *)message
                toRecipients:(NSArray *)recipientPhoneNumbers
           additionalOptions:(NSDictionary *)options
                  errorBlock:(void (^)(NSError *error))errorBlock;

@end
