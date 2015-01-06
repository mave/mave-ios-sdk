//
//  MAVERemoteConfiguration.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import "MAVERemoteConfiguration.h"
#import "MAVERemoteConfigurationContactsPrePromptTemplate.h"

const NSString *MAVERemoteConfigKeyEnableContactsPrePrompt = @"enable_contacts_pre_prompt";
const NSString *MAVERemoteConfigKeyContactsPrePromptTemplate = @"contacts_pre_prompt_template";

@implementation MAVERemoteConfiguration

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [self init]) {
        self.enableContactsPrePrompt = [data objectForKey:MAVERemoteConfigKeyEnableContactsPrePrompt];
        self.contactsPrePromptTemplate = [[MAVERemoteConfigurationContactsPrePromptTemplate alloc] initWithDictionary:[data objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplate]];
    }
    return self;
}

// JSON-formatted data to initiate the remote configuration in its default state
+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyEnableContactsPrePrompt: @YES,
        MAVERemoteConfigKeyContactsPrePromptTemplate:
            [MAVERemoteConfigurationContactsPrePromptTemplate defaultJSONData],
    };
}

@end
