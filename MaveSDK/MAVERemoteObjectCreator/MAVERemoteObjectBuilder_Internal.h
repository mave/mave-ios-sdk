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

@end

#endif
