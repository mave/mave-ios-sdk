//
//  MAVEMerkleTreeLeafNode.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEMerkleTreeNode.h"

@interface MAVEMerkleTreeLeafNode : NSObject<MAVEMerkleTreeNode>

@property (nonatomic, strong) NSArray *dataBucket;
@property (nonatomic, assign) NSRange dataKeyRange;
@property (nonatomic, copy) NSData *(^blockToSerializeDataBucket)(NSArray *dataBucket);

- (instancetype)initWithRange:(NSRange)range
               dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator
   blockToSerializeDataBucket:(NSData *(^)(NSArray *dataBucket))block;

@end