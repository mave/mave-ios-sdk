//
//  MAVERemoteObjectBuilder.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEPromise.h"
#import "MAVERemoteConfigurator.h"

@interface MAVERemoteObjectBuilder : NSObject

// Initialize builder to use response from promise or the hard-coded default data
- (instancetype)initWithClassToCreate:(Class<MAVEDictionaryInitializable>)classToCreate
                        preFetchBlock:(void(^)(MAVEPromise *promise))preFetchBlock
                          defaultData:(NSDictionary *)defaultData;

// Initialize builder to use response from promise and save it to disk if successful.
// Then if a future init fails it tries the saved response and falls back to hard-coded
// default data if that fails.
// - preferLocallySavedData - if true, don't even run the pre-fetch block if there is
// locally saved data we could use instead.
- (instancetype)initWithClassToCreate:(Class<MAVEDictionaryInitializable>)classToCreate
                        preFetchBlock:(void(^)(MAVEPromise *promise))preFetchBlock
                          defaultData:(NSDictionary *)defaultData
    saveIfSuccessfulToUserDefaultsKey:(NSString *)userDefaultsKey
               preferLocallySavedData:(BOOL)preferLocallySavedData;

- (id)createObjectSynchronousWithTimeout:(CGFloat)seconds;
- (void)createObjectWithTimeout:(CGFloat)seconds
                completionBlock:(void (^)(id))completionBlock;

@end
