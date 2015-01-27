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

@protocol MAVEMerkleTreeContainable <NSObject>

// This key is for grouping data for the merkle tree, it should be uniformly
// distributed for all data.
- (NSUInteger)merkleTreeDataKey;

// Representation of the object in a format such that the collection containing
// these data blobs can be serialized *deterministically*
// NB: this means avoiding NSDictionary objects with count > 1 for JSON
//   serialization because JSON objects are unordered. Instead, prefer e.g. a
//   sorted array of 2-tuples to represent the key/value pairs of an object.
- (id)merkleTreeSerializableData;

@end

// Keys for json serialization of merkle tree itself
extern NSString * const MAVEMerkleTreeKeyVal;
extern NSString * const MAVEMerkleTreeLeftChildVal;
extern NSString * const MAVEMerkleTreeRightChildVal;
extern NSString * const MAVEMerkleTreeDataVal;


@interface MAVEMerkleTree : NSObject<MAVEMerkleTreeNode>

+ (id<MAVEMerkleTreeNode>)buildMerkleTreeOfHeight:(NSUInteger)height
                                     withKeyRange:(NSRange)range
                                   dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator;
// Helpers to split range for lower nodes of the tree
+ (BOOL)splitRange:(NSRange)range
         lowerHalf:(NSRange *)lowerRange
         upperHalf:(NSRange *)upperRange;

@end
