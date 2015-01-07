//
//  MAVEPromiseWithDefault.h
//  MaveSDK
//
//  This is not exactly a promise as definied in the spec but it's a similar idea.
//
//  It lets us block on waiting for something to happen, but instead of needing
//  success and error callbacks there's just a success callback and the provided
//  default value is used in place of the actual data if we explicitly call reject
//  or timeout before the promise is fulfilled.
//
//  Created by Danny Cosson on 1/7/15.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MAVEPromiseStatus) {
    MAVEPromiseStatusUnfulfilled = 0,
    MAVEPromiseStatusFulfilled = 1,
    MAVEPromiseStatusRejected = -1,
};

// generic NSValue promise
@interface MAVEPromiseWithDefault : NSObject

@property (nonatomic) NSInteger status;

- (instancetype)initWithDefaultValue:(NSValue *)defaultValue;

- (NSValue *)fulfilledValue;
- (void)setFulfilledValue:(NSValue *)fulfilledValue;
- (NSValue *)defaultValue;
- (void)setDefaultValue:(NSValue *)defaultValue;

- (void)rejectPromise;

// Method to read data from the timeout
// To return immediately use timeout 0
// The value will be fulfilled value if available else the default
// You can also access the "defaultValue" property on the object
//   if you need to, it won't change
- (void)valueWithTimeout:(float)seconds
         completionBlock:(void(^)(NSValue *value))completionBlock;
@end


// NSDictionary promise, just calls [super] methods and casts to NSDictionary
@interface MAVEPromiseWithDefaultDictValues : MAVEPromiseWithDefault

- (instancetype)initWithDefaultValue:(NSDictionary *)defaultValue;

- (NSDictionary *)fulfilledValue;
- (void)setFulfilledValue:(NSDictionary *)fulfilledValue;
- (NSDictionary *)defaultValue;
- (void)setDefaultValue:(NSDictionary *)defaultValue;

- (void)valueWithTimeout:(float)seconds
         completionBlock:(void (^)(NSDictionary *))completionBlock;

@end