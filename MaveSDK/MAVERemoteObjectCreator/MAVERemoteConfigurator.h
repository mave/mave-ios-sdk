//
//  MAVERemoteConfigurator.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MAVEPromiseWithDefault.h"
#import "MAVERemoteConfiguratorDataPersistor.h"

@protocol MAVEDictionaryInitializable <NSObject>
+ (instancetype) alloc;
- (instancetype)initWithDictionary:(NSDictionary *)data;
@end


@interface MAVERemoteConfigurator : NSObject

@property (nonatomic, strong) Class<MAVEDictionaryInitializable> classToCreate;
@property (nonatomic, strong) MAVEPromiseWithDefaultDictValues *promise;
@property (nonatomic, strong) id<MAVEDefaultJSONDataGiver> dataPersistor;

// Initializing the object builder pre-fetches the request with which to build the object
- (instancetype)initWithClassToCreate:(Class<MAVEDictionaryInitializable>)classToCreate
                        preFetchBlock:(void(^)(MAVEPromiseWithDefaultDictValues *promise))preFetchBlock
           userDefaultsPersistanceKey:(NSString *)userDefaultsKey
                          defaultData:(NSDictionary *)defaultData
               preferLocallySavedData:(BOOL)preferLocallySavedData;

- (void)createObjectWithTimeout:(float)seconds
                completionBlock:(void(^)(id object))completionBlock;

@end