//
//  MAVERemoteConfiguratorDataPersistor.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <Foundation/Foundation.h>

@protocol MAVEDefaultJSONDataGiver <NSObject>
- (NSDictionary *)JSONData;
@end

@interface MAVERemoteConfiguratorDataPersistor : NSObject<MAVEDefaultJSONDataGiver>

@property (nonatomic, copy) NSString *userDefaultsKey;
@property (nonatomic, strong) NSDictionary *defaultData;

- (instancetype)initWithUserDefaultsKey:(NSString *)userDefaultsKey
                        defaultJSONData:(NSDictionary *)defaultData;

// Returns stored data or if not available returns the default data
- (NSDictionary *)JSONData;

// Save & load data from the user defaults
// The dictionary data items must be property list compatible
- (void)saveJSONDataToUserDefaults:(NSDictionary *)data;
- (NSDictionary *)loadJSONDataFromUserDefaults;

@end


@interface MAVERemoteConfiguratorDataNonPersistor : NSObject<MAVEDefaultJSONDataGiver>

@property (nonatomic, strong) NSDictionary *defaultData;

// just returns default data
- (NSDictionary *)JSONData;

@end