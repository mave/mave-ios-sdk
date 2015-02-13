//
//  MAVEMerkleTreeDataIterable.h
//  MaveSDK
//
//  This is an enumerator that gives a collection of data with which to build
//  a merkle tree, it's a collection of objects that implement the
//  MAVEMerkleTreeDataItem protocol
//  
//  Created by Danny Cosson on 1/26/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEMerkleTreeProtocols.h"

@interface MAVEMerkleTreeDataEnumerator : NSEnumerator

@property (nonatomic, strong) NSEnumerator *enumerator;
@property (nonatomic, strong) id _nextObject;

- (instancetype)initWithEnumerator:(NSEnumerator *)enumerator;

- (id<MAVEMerkleTreeDataItem>)peekAtNextObject;

- (uint64_t)keyForNextObject;

@end
