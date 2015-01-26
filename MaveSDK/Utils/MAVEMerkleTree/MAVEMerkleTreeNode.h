//
//  MAVEMerkleTreeNode.h
//  MaveSDK
//
//  A merkle tree is a full binary tree of fixed height where each leaf node
//  holds a block of data and each parent node's value is the hash of its
//  two leaf nodes
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import <Foundation/Foundation.h>

extern NSString * const MAVEMerkleTreeKeyVal;
extern NSString * const MAVEMerkleTreeLeftChildVal;
extern NSString * const MAVEMerkleTreeRightChildVal;
extern NSString * const MAVEMerkleTreeDataVal;


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
// Only leaf nodes will have data (and leaf nodes don't have children)
- (NSDictionary *)serializeToJSONObject;

@end

@interface MAVEMerkleTreeInnerNode : NSObject<MAVEMerkleTreeNode>

@property (nonatomic, copy) NSData *hashValue;
@property (nonatomic, strong) id<MAVEMerkleTreeNode> leftChild;
@property (nonatomic, strong) id<MAVEMerkleTreeNode> rightChild;

- (instancetype)initWithLeftChild:(id<MAVEMerkleTreeNode>)leftChild
                       rightChild:(id<MAVEMerkleTreeNode>)rightChild;

@end



@interface MAVEMerkleTreeLeafNode : NSObject<MAVEMerkleTreeNode>

@property (nonatomic, copy) NSData *hashValue;
@property (nonatomic, copy) NSData *data;

- (instancetype)initWithData:(NSData *)data;

@end




