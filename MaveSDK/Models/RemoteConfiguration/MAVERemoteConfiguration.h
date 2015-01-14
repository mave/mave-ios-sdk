//
//  MAVERemoteConfiguration.h
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//  Global remote configuration settings for customizing the app
//  (some of them sdk users configure on our dashboard, some of them
//  we configure server-side to give us the option of changing quickly,
//  A/B testing, having a kill switch, etc.
//
//

#import <Foundation/Foundation.h>
#import "MAVERemoteObjectBuilder.h"
#import "MAVERemoteConfigurationContactsPrePrompt.h"
#import "MAVERemoteConfigurationContactsInvitePage.h"
#import "MAVERemoteConfigurationCustomSharePage.h"
#import "MAVERemoteConfigurationServerSMS.h"
#import "MAVERemoteConfigurationClientSMS.h"
#import "MAVERemoteConfigurationClientEmail.h"
#import "MAVERemoteConfigurationFacebookShare.h"
#import "MAVERemoteConfigurationTwitterShare.h"
#import "MAVERemoteConfigurationClipboardShare.h"

@interface MAVERemoteConfiguration : NSObject<MAVEDictionaryInitializable>

@property (nonatomic, strong) MAVERemoteConfigurationContactsPrePrompt *contactsPrePrompt;
@property (nonatomic, strong) MAVERemoteConfigurationContactsInvitePage *contactsInvitePage;
@property (nonatomic, strong) MAVERemoteConfigurationCustomSharePage *customSharePage;

// Invite & share template
@property (nonatomic, strong) MAVERemoteConfigurationServerSMS *serverSMS;
@property (nonatomic, strong) MAVERemoteConfigurationClientSMS *clientSMS;
@property (nonatomic, strong) MAVERemoteConfigurationClientEmail *clientEmail;
@property (nonatomic, strong) MAVERemoteConfigurationFacebookShare *facebookShare;
@property (nonatomic, strong) MAVERemoteConfigurationTwitterShare *twitterShare;
@property (nonatomic, strong) MAVERemoteConfigurationClipboardShare *clipboardShare;



+ (MAVERemoteObjectBuilder *)remoteBuilder;
+ (NSDictionary *)defaultJSONData;


@end