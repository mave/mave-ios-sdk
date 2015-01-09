//
//  MAVERemoteConfiguration.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import <Foundation/Foundation.h>
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVERemoteConfiguration.h"
#import "MAVERemoteObjectBuilder.h"
#import "MAVERemoteConfigurationContactsPrePromptTemplate.h"

NSString * const MAVEUserDefaultsKeyRemoteConfiguration = @"MAVEUserDefaultsKeyRemoteConfiguration";

const NSString *MAVERemoteConfigKeyEnableContactsPrePrompt = @"enable_contacts_pre_prompt";
const NSString *MAVERemoteConfigKeyContactsPrePromptTemplate = @"contacts_pre_prompt_template";


@implementation MAVERemoteConfiguration

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        self.enableContactsPrePrompt = [data objectForKey:MAVERemoteConfigKeyEnableContactsPrePrompt];
        self.contactsPrePromptTemplate = [[MAVERemoteConfigurationContactsPrePromptTemplate alloc] initWithDictionary:[data objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplate]];
    }
    return self;
}

+ (MAVERemoteObjectBuilder *)remoteBuilder {
    return [[MAVERemoteObjectBuilder alloc]
            initWithClassToCreate:[self class]
            preFetchBlock:^(MAVEPromise *promise) {
                [[MaveSDK sharedInstance].APIInterface
                 getRemoteConfigurationWithCompletionBlock:^(NSError *error, NSDictionary *responseData) {
                     if (error) {
                         [promise rejectPromise];
                     } else {
                         [promise fulfillPromise:(NSValue *)responseData];
                     }
                 }];
            } defaultData:[self defaultJSONData]
            saveIfSuccessfulToUserDefaultsKey:MAVEUserDefaultsKeyRemoteConfiguration
            preferLocallySavedData:NO];
}

+ (NSDictionary *)defaultJSONData {
    return @{
             MAVERemoteConfigKeyEnableContactsPrePrompt: @YES,
             MAVERemoteConfigKeyContactsPrePromptTemplate:
                 [MAVERemoteConfigurationContactsPrePromptTemplate defaultJSONData],
             };
}

@end
