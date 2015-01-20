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
        self.persistor = [[MAVERemoteObjectBuilderDataPersistor alloc] initWithUserDefaultsKey:userDefaultsKey];
        self.loadedFromDiskData = [self.persistor loadJSONDataFromUserDefaults];
        self.defaultData = defaultData;

        if (preferLocallySavedData && self.loadedFromDiskData) {
            self.promise = nil;
        } else {
            self.promise = [[MAVEPromise alloc] initWithBlock:preFetchBlock];
            // Whenever the promise does return, call our method that initializes the
            // object & saves if successful so that even if the object isn't used during
            // this app session it still gets saved for later use (which is expected
            // behavior, particularly `preferLocallySavedData` is true).
            [self.promise done:^(NSValue *result) {
                [self createObjectSynchronousWithTimeout:0];
            } withTimeout:30];
        }
    }
    return self;
}

- (id)object {
    return [self createObjectSynchronousWithTimeout:0];
}

- (id)createObjectSynchronousWithTimeout:(CGFloat)seconds {
    NSDictionary *data = (NSDictionary *)[self.promise doneSynchronousWithTimeout:seconds];
    return [self buildWithPrimaryThenFallBackToDefaultsWithData:data];
}

- (void)createObjectWithTimeout:(CGFloat)seconds
                completionBlock:(void (^)(id))completionBlock {
    // if no promise just return without promise data
    if (!self.promise ) {
        id output = [self buildWithPrimaryThenFallBackToDefaultsWithData:nil];
        return completionBlock(output);
    }

    // Otherwise call the async promise done block and return that data
    [self.promise done:^(NSValue *result) {
        id output = [self buildWithPrimaryThenFallBackToDefaultsWithData:(NSDictionary *)result];
        completionBlock(output);
    } withTimeout:seconds];

}

- (id)buildWithPrimaryThenFallBackToDefaultsWithData:(NSDictionary *)data {
    // if we've already created the object once, we want to use the same
    // instance of the object. Note that this cached value will only have
    // gotten set if we didn't fall back to the on-disk or hard-coded
    // default value previously
    if (self.createdObject ) {
        return self.createdObject;
    }

    id obj;
    if (data != nil) {
        obj = [self buildObjectUsingData:data];
        if (obj) {
            self.createdObject = obj;
        }
        if (obj && self.persistor) {
            [self.persistor saveJSONDataToUserDefaults:data];
        }
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
