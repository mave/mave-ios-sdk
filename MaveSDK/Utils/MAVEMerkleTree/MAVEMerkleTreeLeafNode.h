//
//  MAVEMerkleTreeLeafNode.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEMerkleTreeProtocols.h"
#import "MAVEMerkleTreeDataEnumerator.h"

@interface MAVEMerkleTreeLeafNode : NSObject<MAVEMerkleTreeNode>

@property (nonatomic, strong) NSArray *dataBucket;
@property (nonatomic, assign) NSRange dataKeyRange;

- (instancetype)initWithRange:(NSRange)range
               dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator;

// Returns data collection in a format that can be JSON serialized
- (NSArray *)serializeableData;

// Returns the NSData by calling MAVEMerkleTree's serialization method
- (NSData *)serializeData;

@end