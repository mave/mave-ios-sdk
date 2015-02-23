//
//  MAVEPromise.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MAVEPromiseStatus) {
    MAVEPromiseStatusUnfulfilled = 0,
    MAVEPromiseStatusFulfilled = 1,
    MAVEPromiseStatusRejected = -1,
};

@interface MAVEPromise : NSObject

@property (nonatomic) MAVEPromiseStatus status;

// Create promise and start running the block
// The block is responsible for fulfilling or rejecting the promise it
// gets passed
- (instancetype)initWithBlock:(void(^)(MAVEPromise *promise))runBlock;

// Method to fulfill the promise.
// If the value is nil, that is the same as rejecting the promise.
// Use [NSNull null] if the promise value should actually be null.
- (void)fulfillPromise:(NSValue *)value;
- (void)rejectPromise;

- (NSValue *)doneSynchronousWithTimeout:(CGFloat)seconds;
- (void)done:(void(^)(NSValue *result))completionBlock
 withTimeout:(CGFloat)seconds;

// Not yet implemented but I think this would be the signature
//- (instancetype)then:(MAVEPromise *(^)(NSValue *result))completionBlock
//         withTimeout:(CGFloat)seconds;

@end
