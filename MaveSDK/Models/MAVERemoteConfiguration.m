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
#import "MAVERemoteConfigurator.h"
#import "MAVERemoteConfiguration.h"
#import "MAVERemoteConfigurationContactsPrePromptTemplate.h"

NSString * const MAVEUserDefaultsKeyRemoteConfiguration = @"MAVEUserDefaultsKeyRemoteConfiguration";

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

+ (MAVERemoteConfigurator *)remoteConfigurationBuilder {
    return [[MAVERemoteConfigurator alloc]
            initWithClassToCreate:[self class]
            preFetchBlock:^(MAVEPromiseWithDefaultDictValues *promise) {
                [[MaveSDK sharedInstance].APIInterface
                getRemoteConfigurationWithCompletionBlock:^(NSError *error, NSDictionary *responseData) {
                    if (error) {
                        [promise rejectPromise];
                    } else {
                        promise.fulfilledValue = responseData;
                    }
                }];
            } userDefaultsPersistanceKey:MAVEUserDefaultsKeyRemoteConfiguration
            defaultData:[self defaultJSONData]
            preferLocallySavedData:NO];
}

+ (NSDictionary *)defaultJSONData {
    NSDictionary *data = [self loadJSONDataFromUserDefaults];
    if (!data) {
        data = [self defaultDefaultJSONData];
    }
    return data;
}

+ (NSDictionary *)defaultDefaultJSONData {
    return @{
        MAVERemoteConfigKeyEnableContactsPrePrompt: @YES,
        MAVERemoteConfigKeyContactsPrePromptTemplate:
            [MAVERemoteConfigurationContactsPrePromptTemplate defaultJSONData],
    };
}

+ (NSString *)userDefaultsKey {
    return @"MAVEUserDefaultsKeyRemoteConfiguration";
}

+ (void)saveJSONDataToUserDefaults:(NSDictionary *)data {
    // use try/catch b/c we can have an error if data is not a property list, and
    // probably if disk is full and all the other usual suspects when doing I/O
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data
                         forKey:[self userDefaultsKey]];
        [userDefaults synchronize];
    }
    @catch (NSException *exception) {
        DebugLog(@"Error saving data!");
    }
}

+ (NSDictionary *)loadJSONDataFromUserDefaults {
    NSDictionary *data;
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        data = [userDefaults dictionaryForKey:[self userDefaultsKey]];
    }
    @catch (NSException *exception) {
        data = nil;
    }
    @finally {
        return data;
    }
}

@end
