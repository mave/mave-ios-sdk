//
//  MAVERemoteConfiguratorDataPersistor.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVERemoteObjectBuilderDataPersistor : NSObject

@property (nonatomic, copy) NSString *userDefaultsKey;

// helper to return the user defaults we want
- (NSUserDefaults *)userDefaults;

- (instancetype)initWithUserDefaultsKey:(NSString *)userDefaultsKey;

// Save & load data from the user defaults
// The dictionary data items must be property list compatible
- (void)saveJSONDataToUserDefaults:(NSDictionary *)data;
- (NSDictionary *)loadJSONDataFromUserDefaults;
- (void)wipeJSONData;

@end
