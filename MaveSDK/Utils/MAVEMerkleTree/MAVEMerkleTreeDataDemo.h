//
//  MAVEMerkleTreeDataDemo.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/27/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEMerkleTreeNodeProtocol.h"

// This is a demo class to show how to implement
// MAVEMerkleTreeContainable.
// It's just an object wrapper around an NSUInteger
@interface MAVEMerkleTreeDataDemo : NSObject<MAVEMerkleTreeContainable>

@property (nonatomic, assign) NSUInteger value;

- (instancetype)initWithValue:(NSUInteger)value;

@end
