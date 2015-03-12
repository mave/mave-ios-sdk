//
//  MAVERemoteObjectBuilder.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEPromise.h"

@protocol MAVEDictionaryInitializable <NSObject>
+ (instancetype)alloc;
- (instancetype)initWithDictionary:(NSDictionary *)data;
@end

@interface MAVERemoteObjectBuilder : NSObject

// The underlying promise object for coordinating between the setting and getting of
// the data. Only need to use this explicitly if you don't pass in a preFetchBlock
// and want to, say,
@property (atomic, strong) MAVEPromise *promise;

// Initialize builder to use response from promise or the hard-coded default data.
// If preFetchBlock is nil we won't pre-fetch the data now, do this if you're planning to fulfill
//     the promise elsewhere in your code later
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

// Create the object synchronously. If timeout > 0, this may block the current
// execution thread for up to that lock.
// You can safely cast the returned id object to the type of the `classToCreate` passed in
- (id)createObjectSynchronousWithTimeout:(CGFloat)seconds;

// Alias for create synchronous with timeout 0, lets you use dot accessors
- (id)object;

// Create the object asynchronously, created object is passed to a block.
// You can safely cast the returned id object to the type of the `classToCreate` passed in
- (void)createObjectWithTimeout:(CGFloat)seconds
                completionBlock:(void (^)(id object))completionBlock;

@end
