//
//  MAVERemoteObjectBuilder_Internal.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import "MAVERemoteObjectBuilder.h"
#import "MAVEPromise.h"
#import "MAVERemoteObjectBuilderDataPersistor.h"

#ifndef MaveSDK_MAVERemoteObjectBuilder_Internal_h
#define MaveSDK_MAVERemoteObjectBuilder_Internal_h

@interface MAVERemoteObjectBuilder ()

@property (atomic) id classToCreate;
@property (atomic, strong) MAVERemoteObjectBuilderDataPersistor *persistor;
@property (atomic, strong) NSDictionary *loadedFromDiskData;
@property (atomic, strong) NSDictionary *defaultData;
@property (atomic, strong) id createdObject;

// Helper to try building with this data, then try relevant fallbacks
- (id)buildWithPrimaryThenFallBackToDefaultsWithData:(NSDictionary *)data;

// internal helper to build the object using this one piece of data
- (id)buildObjectUsingData:(NSDictionary *)data;

@end

#endif
