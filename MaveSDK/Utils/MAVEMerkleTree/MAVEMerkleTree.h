//
//  MAVEMerkleTree.h
//  MaveSDK
//
//  A Merkle Tree is use to find changes between two copies of a data set without
//  having to replay a log of all changes to the data.  Given a collection of objects
//  with uniformly distributed keys (can hash a natural key to make sure this holds),
//  put them into buckets based on key ranges, then hash the contents of the buckets
//  such that each node in the tree is the hash of its two children's hashes.
//
//  The height of the tree is arbitrary and fixed, and the number of buckets is the
//  number of leaf nodes, so 2^(height -1).
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEMerkleTreeNodeProtocol.h"
#import "MAVEMerkleTreeDataEnumerator.h"


@interface MAVEMerkleTree : NSObject<MAVEMerkleTreeNode>

+ (id<MAVEMerkleTreeNode>)buildMerkleTreeOfHeight:(NSUInteger)height
                                     withKeyRange:(NSRange)range
                                   dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator;
// Helpers to split range for lower nodes of the tree
+ (BOOL)splitRange:(NSRange)range
         lowerHalf:(NSRange *)lowerRange
         upperHalf:(NSRange *)upperRange;

@end
