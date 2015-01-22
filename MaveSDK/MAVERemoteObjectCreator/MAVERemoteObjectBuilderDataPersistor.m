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
    if (self = [self init]) {
        self.userDefaultsKey = userDefaultsKey;
    }
    return self;
}

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (void)saveJSONDataToUserDefaults:(NSDictionary *)data {
    // use try/catch for json serialization and any possible I/O errors
    @try {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:0 error:nil];
        if (!jsonData) {
            return;
        }
        [self.userDefaults setObject:jsonData forKey:self.userDefaultsKey];
        [self.userDefaults synchronize];
    }
    @catch (NSException *exception) {
        // Data could not be saved
    }
}

- (NSDictionary *)loadJSONDataFromUserDefaults {
    NSDictionary *output;
    @try {
        NSData *data = [self.userDefaults objectForKey:self.userDefaultsKey];
        output = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0 error:nil];
    }
    @catch (NSException *exception) {
        output = nil;
    }
    @finally {
        if (output == nil) {
            [self wipeJSONData];
        }
        return output;
    }
}

- (void)wipeJSONData {
    [self.userDefaults removeObjectForKey:self.userDefaultsKey];
}

@end
