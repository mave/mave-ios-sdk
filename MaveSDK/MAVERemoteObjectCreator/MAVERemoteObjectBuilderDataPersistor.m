//
//  MAVERemoteConfiguratorDataPersistor.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import "MAVERemoteObjectBuilderDataPersistor.h"

@implementation MAVERemoteObjectBuilderDataPersistor

- (instancetype) initWithUserDefaultsKey:(NSString *)userDefaultsKey {
    if (self = [super init]) {
        self.userDefaultsKey = userDefaultsKey;
    }
    return self;
}

- (void)saveJSONDataToUserDefaults:(NSDictionary *)data {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:0 error:nil];
    if (!jsonData) {
        return;
    }
    // use try/catch b/c we can have probably still have errors, e.g. disk
    // is full and all the other usual I/O suspects
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:jsonData forKey:self.userDefaultsKey];
        [userDefaults synchronize];
    }
    @catch (NSException *exception) {
        // Data could not be saved
    }
}

- (NSDictionary *)loadJSONDataFromUserDefaults {
    NSDictionary *output;
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [userDefaults dataForKey:self.userDefaultsKey];
        output = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0 error:nil];
    }
    @catch (NSException *exception) {
        output = nil;
    }
    @finally {
        return output;
    }
}

@end
