//
//  MAVEMerkleTreeNodeProtocol.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/27/15.
//
//

#ifndef MaveSDK_MAVEMerkleTreeNodeProtocol_h
#define MaveSDK_MAVEMerkleTreeNodeProtocol_h

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
