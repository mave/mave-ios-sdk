//
//  MAVERemoteConfiguratorDataPersistor.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import "MAVERemoteConfiguratorDataPersistor.h"

@implementation MAVERemoteConfiguratorDataPersistor

- (instancetype) initWithUserDefaultsKey:(NSString *)userDefaultsKey
                         defaultJSONData:(NSDictionary *)defaultData {
    if (self = [super init]) {
        self.userDefaultsKey = userDefaultsKey;
        self.defaultData = defaultData;
    }
    return self;
}

- (NSDictionary *)JSONData {
    NSDictionary *data = [self loadJSONDataFromUserDefaults];
    if (!data) {
        data = self.defaultData;
    }
    return data;
}

- (void)saveJSONDataToUserDefaults:(NSDictionary *)data {
    if (![NSPropertyListSerialization propertyList:data
                                 isValidForFormat:NSPropertyListBinaryFormat_v1_0]) {
        return;
    }
    // use try/catch b/c we can have probably still have errors, e.g. disk
    // is full and all the other usual I/O suspects
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data
                         forKey:self.userDefaultsKey];
        [userDefaults synchronize];
    }
    @catch (NSException *exception) {
        // Data could not be saved
    }
}

- (NSDictionary *)loadJSONDataFromUserDefaults {
    NSDictionary *data;
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        data = [userDefaults dictionaryForKey:self.userDefaultsKey];
    }
    @catch (NSException *exception) {
        data = nil;
    }
    @finally {
        return data;
    }
}

@end
