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

@interface MAVEMerkleTreeNode : NSObject

@property (nonatomic, copy) NSString *key;



@end



@interface MAVEMerkleTreeInnerNode : MAVEMerkleTreeNode

@property (nonatomic, strong) MAVEMerkleTreeNode *leftChild;
@property (nonatomic, strong) MAVEMerkleTreeNode *rightChild;

@end



@interface MAVEMerkleTreeLeafNode : MAVEMerkleTreeNode

@property (nonatomic, copy) NSData *data;

@end
