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
#import "MAVERange64.h"
#import "MAVEMerkleTreeProtocols.h"
#import "MAVEMerkleTreeDataEnumerator.h"

typedef NSUInteger MAVEMerkleTreePath;

@interface MAVEMerkleTree : NSObject

@property (nonatomic, strong) id<MAVEMerkleTreeNode>root;


- (instancetype)initWithHeight:(NSUInteger)height
                     arrayData:(NSArray *)data
                  dataKeyRange:(MAVERange64)keyRange
             hashValueNumBytes:(NSInteger)hashValueNumBytes;

+ (instancetype)emptyTreeWithHashValueNumBytes:(NSInteger)hashValueNumBytes;

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject;

// Helper to get height of tree
- (NSUInteger)height;

// Method to determine how to update the given other merkle tree to match self
//
// This object needs valid data to build the changeset, but the other tree
//    argument does not (it will typically be just the hash tree returned over
//    the network representing a remote object).
//
// Format of return value is array of tuples (NSArrays) with each tuple like:
//   [ <path to differing leaf node>,
//     <reference tree hash value>,
//     <data from reference tree> ]
//   - path: has format NSUInteger where each bit represents 0 for traversing to left child
//           next or 1 for right child, starting with the least significant bit at the root
//   - hash value: as hex-encoded string
//   - data: the data bucket in a format where it can be serialized
- (NSArray *)changesetForOtherTreeToMatchSelf:(MAVEMerkleTree *)otherTree;
- (NSArray *)changesetForEmptyTreeToMatchSelf;

// Returns the tree in a JSON serializable representation
- (NSDictionary *)serializable;

+ (id<MAVEMerkleTreeNode>)buildMerkleTreeOfHeight:(NSUInteger)height
                                     withKeyRange:(MAVERange64)range
                                   dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator
                                hashValueNumBytes:(NSUInteger)hashValueNumBytes;

+ (id<MAVEMerkleTreeNode>)buildMerkleTreeFromJSONObject:(NSDictionary *)jsonObject;

+ (NSArray *)changesetReferenceSubtree:(id<MAVEMerkleTreeNode>)referenceTree
                 matchedByOtherSubtree:(id<MAVEMerkleTreeNode>)otherTree
                     currentPathToNode:(MAVEMerkleTreePath)currentPath;

// Helper for the above methods
+ (BOOL)splitRange:(MAVERange64)range
         lowerHalf:(MAVERange64 *)lowerRange
         upperHalf:(MAVERange64 *)upperRange;

@end
