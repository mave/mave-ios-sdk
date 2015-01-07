//
//  MAVERemoteConfiguratorDataPersistor.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVERemoteConfiguratorDataPersistor : NSObject

@property (nonatomic, copy) NSString *userDefaultsKey;
@property (nonatomic, strong) NSDictionary *defaultData;

- (instancetype)initWithUserDefaultsKey:(NSString *)userDefaultsKey
                        defaultJSONData:(NSDictionary *)defaultData;

// Return stored data or if not available the default data
- (NSDictionary *)JSONData;

// Save & load data from the user defaults
// The dictionary data items must be property list compatible
- (void)saveJSONDataToUserDefaults:(NSDictionary *)data;
- (NSDictionary *)loadJSONDataFromUserDefaults;

@end
