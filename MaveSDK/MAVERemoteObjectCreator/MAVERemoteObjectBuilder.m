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
    }
    return self;
}



@end
