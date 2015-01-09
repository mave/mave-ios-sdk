//
//  MAVERemoteObjectBuilder.m
//  MaveSDK
//
//  Builds object from remote configuration (JSON dict) or from default data
//  if the remote call fails or hasn't yet returned by the time the response
//  is needed.
//
//  The default data can (optionally) be the last successful remote response
//  which gets written to disk when successfully used. If this is disabled
//  or the saved data also fails to initialize the object the hard-coded default
//  data will be used.
//
//  Created by Danny Cosson on 1/9/15.
//

#import "MAVERemoteObjectBuilder.h"
#import "MAVERemoteObjectBuilder_Internal.h"

@implementation MAVERemoteObjectBuilder

- (instancetype)initWithClassToCreate:(Class<MAVEDictionaryInitializable>)classToCreate
                        preFetchBlock:(void (^)(MAVEPromise *))preFetchBlock
                          defaultData:(NSDictionary *)defaultData {
    if (self = [super init]) {
        self.classToCreate = classToCreate;
        self.promise = [[MAVEPromise alloc] initWithBlock:preFetchBlock];
        self.defaultData = defaultData;
    }
    return self;
}

- (instancetype)initWithClassToCreate:(Class<MAVEDictionaryInitializable>)classToCreate
                        preFetchBlock:(void (^)(MAVEPromise *))preFetchBlock
                          defaultData:(NSDictionary *)defaultData
    saveIfSuccessfulToUserDefaultsKey:(NSString *)userDefaultsKey
               preferLocallySavedData:(BOOL)preferLocallySavedData {
    if (self = [super init]) {
        self.classToCreate = classToCreate;
        if (!preferLocallySavedData) {
            self.promise = [[MAVEPromise alloc] initWithBlock:preFetchBlock];
        }
        MAVERemoteConfiguratorDataPersistor *persistor =
        [[MAVERemoteConfiguratorDataPersistor alloc] initWithUserDefaultsKey:userDefaultsKey defaultJSONData:defaultData];
        self.loadedFromDiskData = [persistor loadJSONDataFromUserDefaults];
        self.defaultData = defaultData;
    }
    return self;
}

- (id)createObjectSynchronousWithTimeout:(CGFloat)seconds {
    NSDictionary *data = (NSDictionary *)[self.promise doneSynchronousWithTimeout:seconds];
    return [self buildWithPrimaryThenFallBackToDefaultsWithData:data];
}

- (void)createObjectWithTimeout:(CGFloat)seconds
                completionBlock:(void (^)(id))completionBlock {
    [self.promise done:^(NSValue *result) {
        id output = [self buildWithPrimaryThenFallBackToDefaultsWithData:(NSDictionary *)result];
        completionBlock(output);
    } withTimeout:seconds];

}

- (id)buildWithPrimaryThenFallBackToDefaultsWithData:(NSDictionary *)data {
    id obj;
    if (data != nil) {
        obj = [self buildObjectUsingData:data];
    }
    if (!obj && self.loadedFromDiskData != nil) {
        obj = [self buildObjectUsingData:self.loadedFromDiskData];
    }
    if (!obj && self.defaultData != nil) {
        obj = [self buildObjectUsingData:self.defaultData];
    }
    return obj;
}

- (id)buildObjectUsingData:(NSDictionary *)data {
    id output;
    @try {
        output = [[self.classToCreate alloc] initWithDictionary:data];
    }
    @catch (NSException *exception) {
        output = nil;
    }
    return output;
}



@end
