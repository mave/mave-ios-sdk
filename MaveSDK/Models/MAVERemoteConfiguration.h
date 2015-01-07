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
#import "MAVEPendingResponseObjectBuilder.h"
#import "MAVERemoteConfigurationContactsPrePromptTemplate.h"


@interface MAVERemoteConfiguration : NSObject<MAVEDictionaryInitializable>

@property (nonatomic) NSNumber *enableContactsPrePrompt;
@property (nonatomic, strong) MAVERemoteConfigurationContactsPrePromptTemplate *contactsPrePromptTemplate;

// data to use if we can't load configuration from server.
// The last correct response we got will have been saved so this method should
// return that, but on the first app open it returns a hard-coded default
+ (NSDictionary *)defaultJSONData;
// this is the hard-coded default
+ (NSDictionary *)defaultDefaultJSONData;

// helpers to save & load to/from json dictionary
+ (NSString *)userDefaultsKey;
+ (void)saveJSONDataToUserDefaults:(NSDictionary *)data;
+ (NSDictionary *)loadJSONDataFromUserDefaults;

@end