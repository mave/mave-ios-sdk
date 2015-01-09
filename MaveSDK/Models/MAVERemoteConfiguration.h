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
#import "MAVERemoteConfigurationContactsPrePromptTemplate.h"

extern NSString * const MAVEUserDefaultsKeyRemoteConfiguration;


@interface MAVERemoteConfiguration : NSObject<MAVEDictionaryInitializable>

@property (nonatomic) NSNumber *enableContactsPrePrompt;
@property (nonatomic, strong) MAVERemoteConfigurationContactsPrePromptTemplate *contactsPrePromptTemplate;

+ (MAVERemoteObjectBuilder *)remoteBuilder;
+ (NSDictionary *)defaultJSONData;


@end