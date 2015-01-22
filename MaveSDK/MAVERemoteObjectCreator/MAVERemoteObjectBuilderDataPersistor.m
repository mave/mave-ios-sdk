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
    // Don't save empty data
    if (!data || data ==(id)[NSNull null]) {
        return;
    }
    // use try/catch for json serialization and any possible I/O errors
    @try {
        NSError *jsonError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:0
                                                             error:&jsonError];
        if (jsonError) {
#if DEBUG
            NSLog(@"MAVERemoteObjectBuilder - error %@ archiving data for user defaults key %@",
                  jsonError, self.userDefaultsKey);
#endif
            return;
        }
        [self.userDefaults setObject:jsonData forKey:self.userDefaultsKey];
        [self.userDefaults synchronize];
    }
    @catch (NSException *exception) {
        // Data could not be saved
#if DEBUG
        NSLog(@"MAVERemoteObjectBuilder - error saving data to user defaults key %@",
              self.userDefaultsKey);
#endif
    }
}

- (NSDictionary *)loadJSONDataFromUserDefaults {
    NSDictionary *output;
    @try {
        NSData *jsonData = [self.userDefaults objectForKey:self.userDefaultsKey];
        if (!jsonData) {
            return nil;
        }
        NSError *jsonError;
        output = [NSJSONSerialization JSONObjectWithData:jsonData
                                                 options:0
                                                   error:&jsonError];
        if (jsonError) {
#ifdef DEBUG
            NSLog(@"MAVERemoteObjectBuilder - error %@ unarchiving data for user defaults key %@, wiping the corrupted record",
                  jsonError, self.userDefaultsKey);
#endif
            [self wipeJSONData];
            return nil;
        }
    }
    @catch (NSException *exception) {
        output = nil;
    }
    if (output == nil) {
#ifdef DEBUG
        NSLog(@"MAVERemoteObjectBuilder - error loading data from defaults key %@, wiping the corrupted record",
              self.userDefaultsKey);
#endif
        [self wipeJSONData];
    }
    return output;
}

- (void)wipeJSONData {
    [self.userDefaults removeObjectForKey:self.userDefaultsKey];
}

@end
