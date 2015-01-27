//
//  MAVEMerkleTreeDataIterable.h
//  MaveSDK
//
//  This is an enumerator that gives a collection of data with which to build
//  a merkle tree, it's a collection of objects that implement the
//  MAVEMerkleTreeContainable protocol
//  
//  Created by Danny Cosson on 1/26/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEMerkleTreeNodeProtocol.h"

@interface MAVEMerkleTreeDataEnumerator : NSEnumerator

@property (nonatomic, strong) NSEnumerator *enumerator;
@property (nonatomic, strong) id _nextObject;
@property (nonatomic, copy) NSData *(^blockToSerializeDataBucket)(NSArray *array);

- (instancetype)initWithEnumerator:(NSEnumerator *)enumerator
        blockToSerializeDataBucket:(NSData *(^)(NSArray *array))block;

- (id<MAVEMerkleTreeContainable>)peekAtNextObject;

- (NSUInteger)keyForNextObject;

@end
