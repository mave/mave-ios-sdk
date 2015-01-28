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
#import "MAVEMerkleTreeProtocols.h"
#import "MAVEMerkleTreeDataEnumerator.h"

typedef NSUInteger MAVEMerkleTreePath;

@interface MAVEMerkleTree : NSObject

+ (id<MAVEMerkleTreeNode>)buildMerkleTreeOfHeight:(NSUInteger)height
                                     withKeyRange:(NSRange)range
                                   dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator;

// Method to determine how to update a given merkle tree to match another.
// The `referenceTree` argument needs to contain the data values but `otherTree`
// does not (it will likely be just the hash tree from a remote source).
//
// Format of data returned is an array of tuples (NSArrays) with each tuple like:
//   [<path to differing leaf node>, <reference tree hash value>, <data from reference tree>]
//   - path: has format NSUInteger where each bit represents 0 for traversing to left child
//           next or 1 for right child, starting with the least significant bit at the root
//   - hash value: as hex-encoded string
//   - data: the data bucket in a format where it can be serialized
+ (NSArray *)differencesToMakeTree:(id<MAVEMerkleTreeNode>)otherTree
                         matchTree:(id<MAVEMerkleTreeNode>)referenceTree
                 currentPathToNode:(MAVEMerkleTreePath)currentPath;

// Helper for the above methods
+ (BOOL)splitRange:(NSRange)range
         lowerHalf:(NSRange *)lowerRange
         upperHalf:(NSRange *)upperRange;

@end
