//
//  MAVEMerkleTreeInnerNode.h
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
#import "MAVEMerkleTreeProtocols.h"
#import "MAVEMerkleTreeDataEnumerator.h"


@interface MAVEMerkleTreeInnerNode : NSObject<MAVEMerkleTreeNode>

@property (nonatomic, strong) id<MAVEMerkleTreeNode> leftChild;
@property (nonatomic, strong) id<MAVEMerkleTreeNode> rightChild;

- (instancetype)initWithLeftChild:(id<MAVEMerkleTreeNode>)leftChild
                       rightChild:(id<MAVEMerkleTreeNode>)rightChild;

- (void)setHashValueWhenBuildingFromJSON:(NSData *)hashValue;

@end




