//
//  MAVERemoteConfigurator.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import "MAVERemoteConfigurator.h"

@implementation MAVERemoteConfigurator

- (instancetype)initWithClassToCreate:(Class<MAVEDictionaryInitializable>)classToCreate
                        preFetchBlock:(void(^)(MAVEPromiseWithDefaultDictValues *promise))preFetchBlock
           userDefaultsPersistanceKey:(NSString *)userDefaultsKey
                          defaultData:(NSDictionary *)defaultData
               preferLocallySavedData:(BOOL)preferLocallySavedData {
    if (self = [super init]) {
        self.classToCreate = classToCreate;
        self.dataPersistor =
            [[MAVERemoteConfiguratorDataPersistor alloc] initWithUserDefaultsKey:userDefaultsKey
                                                                 defaultJSONData:defaultData];
        self.promise = [[MAVEPromiseWithDefaultDictValues alloc]
                        initWithDefaultValue:[self.dataPersistor JSONData]];
        preFetchBlock(self.promise);
    }
    return self;
}

- (void)createObjectWithTimeout:(float)seconds
                completionBlock:(void (^)(id))completionBlock {
    [self.promise valueWithTimeout:seconds completionBlock:^(NSDictionary * data) {
        id output = [self createObjectWithData:data orDefaultData:self.promise.defaultValue];
        completionBlock(output);
    }];
}

- (id)createObjectWithData:(NSDictionary *)data orDefaultData:(NSDictionary *)defaultData {
    id returnObject;
    @try {
        // if responseData is malformed, this returns nil or raises exception
        returnObject = [[self.classToCreate alloc] initWithDictionary:data];

    }
    @catch (NSException *exception) {
        returnObject = nil;
    }

    if (returnObject ) {
        // The primary returned data worked
        [((MAVERemoteConfiguratorDataPersistor *)self.dataPersistor)
         saveJSONDataToUserDefaults:data];
    } else {
        // Fall back to default data if couldn't initialize with the returned data.
        // This should not fail because it's known working default data
        NSDictionary *defaultData = self.promise.defaultValue;
        returnObject = [[self.classToCreate alloc] initWithDictionary: defaultData];

        [((MAVERemoteConfiguratorDataPersistor *)self.dataPersistor)
         saveJSONDataToUserDefaults:defaultData];
    }

    return returnObject;
}

@end
