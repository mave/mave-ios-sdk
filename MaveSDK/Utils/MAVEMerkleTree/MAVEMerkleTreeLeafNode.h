//
//  MAVEMerkleTreeLeafNode.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEMerkleTreeProtocols.h"
#import "MAVERange64.h"
#import "MAVEMerkleTreeDataEnumerator.h"

@interface MAVEMerkleTreeLeafNode : NSObject<MAVEMerkleTreeNode>

@property (nonatomic, strong) NSArray *dataBucket;
@property (nonatomic, assign) MAVERange64 dataKeyRange;
@property (nonatomic, assign) NSInteger hashValueNumBytes;

- (instancetype)initWithRange:(MAVERange64)range
               dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator
            hashValueNumBytes:(NSInteger)hashValueNumBytes;

// This is when initializing from a remote source, we'll have the hash value
// directly but we won't have the data
- (instancetype)initWithHashValue:(NSData *)hashValue;

// Returns data collection in a format that can be JSON serialized
- (NSArray *)serializeableData;

// Returns the NSData by calling MAVEMerkleTree's serialization method
- (NSData *)serializedData;

@end
