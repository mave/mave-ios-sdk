//
//  MAVERemoteObjectBuilder_Internal.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import "MAVERemoteObjectBuilder.h"
#import "MAVEPromise.h"
#import "MAVERemoteConfiguratorDataPersistor.h"

#ifndef MaveSDK_MAVERemoteObjectBuilder_Internal_h
#define MaveSDK_MAVERemoteObjectBuilder_Internal_h

@interface MAVERemoteObjectBuilder ()

@property (nonatomic, strong) MAVEPromise *promise;
@property (nonatomic) id classToCreate;
@property (nonatomic, strong) MAVERemoteConfiguratorDataPersistor *persistor;
@property (nonatomic, strong) NSDictionary *loadedFromDiskData;
@property (nonatomic, strong) NSDictionary *defaultData;

// Helper to try building with this data, then try relevant fallbacks
- (id)buildWithPrimaryThenFallBackToDefaultsWithData:(NSDictionary *)data;

// internal helper to build the object using this one piece of data
- (id)buildObjectUsingData:(NSDictionary *)data;

@end

#endif
