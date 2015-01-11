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
#import "MAVERemoteConfigurationClientSMS.h"

extern NSString * const MAVEUserDefaultsKeyRemoteConfiguration;


@interface MAVERemoteConfiguration : NSObject<MAVEDictionaryInitializable>

@property (nonatomic, strong) MAVERemoteConfigurationContactsPrePrompt *contactsPrePrompt;
@property (nonatomic, strong) MAVERemoteConfigurationContactsInvitePage *contactsInvitePage;
// Client share page templates
@property (nonatomic, strong) MAVERemoteConfigurationClientSMS *clientSMS;


+ (MAVERemoteObjectBuilder *)remoteBuilder;
+ (NSDictionary *)defaultJSONData;


@end