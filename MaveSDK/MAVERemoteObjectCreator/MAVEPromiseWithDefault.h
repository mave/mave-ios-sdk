//
//  MAVEPromiseWithDefault.h
//  MaveSDK
//
//  A Promise object, lets you block on waiting for something to happen.
//  If fulfilled by the timeout it returns the new value, if it is
//  rejected or still waiting to be fulfilled it returns the default
//  value you set when initializing it.
//  Created by Danny Cosson on 1/7/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MAVEPromiseStatus) {
    MAVEPromiseStatusUnfulfilled = 0,
    MAVEPromiseStatusFulfilled = 1,
    MAVEPromiseStatusRejected = -1,
};

@interface MAVEPromiseWithDefault : NSObject

@property (nonatomic) NSInteger status;
@property (nonatomic, strong) NSValue *fulfilledValue;
@property (nonatomic, strong) NSValue *defaultValue;

- (instancetype)initWithDefaultValue:(NSValue *)defaultValue;

- (void)setFulfilledValue:(NSValue *)fulfilledValue;
- (void)reject;

// Method to read data from the timeout
// To return immediately use timeout 0
// The value will be fulfilled value if available else the default
// You can also access the "defaultValue" property on the object
//   if you need to, it won't change
- (void)valueWithTimeout:(float)timeout
         completionBlock:(void(^)(NSValue *value))completionBlock;

@end

@interface MAVEPromiseWithDefaultDictValues : MAVEPromiseWithDefault

- (instancetype)initWithDefaultValue:(NSValue *)defaultValue;

- (void)setFulfilledValue:(NSDictionary *)fulfilledValue;
- (void)reject;

@end
