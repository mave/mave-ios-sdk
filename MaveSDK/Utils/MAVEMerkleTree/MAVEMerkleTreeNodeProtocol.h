//
//  MAVEMerkleTreeNodeProtocol.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/27/15.
//
//

#ifndef MaveSDK_MAVEMerkleTreeNodeProtocol_h
#define MaveSDK_MAVEMerkleTreeNodeProtocol_h

///
/// Public protocol for data item, a collection of which can build a
///   merkle tree
///
@protocol MAVEMerkleTreeDataItem <NSObject>

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


///
/// Internal protocol, methods shared btwn inner & leaf nodes
///
@protocol MAVEMerkleTreeNode <NSObject>

// The hash value in a merkle tree is the hash of the subtree.
// Should be cached forever after being computed, but this is ok
// because merkle tree is immutable
- (NSData *)hashValue;

// The simple serialization format for a merkle tree node is the dict:
// { @"k": <hash value hex string>,
//   @"l": <serialized left child>,
//   @"r": <serialized right child>,
//   @"d": <base64-encoded data>
// }
// Only leaf nodes will have data, and only inner nodes will have l and r
// children
- (NSDictionary *)serializeToJSONObject;

// Traverses subtree downward to find height
- (NSUInteger)treeHeight;

@end

#endif
