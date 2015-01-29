//
//  MAVEMerkleTreeLeafNode.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import "MAVEMerkleTreeLeafNode.h"
#import "MAVEMerkleTreeUtils.h"
#import "MAVEHashingUtils.h"

@implementation MAVEMerkleTreeLeafNode {
    NSData *_hashValue;
}

- (instancetype)initWithRange:(NSRange)range
               dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator {
    if (self = [super init]) {
        self.dataKeyRange = range;
        [self loadDataIntoBucket:enumerator];
    }
    return self;
}

- (instancetype)initWithHashValue:(NSData *)hashValue {
    if (self = [super init]) {
        _hashValue = hashValue;
    }
    return self;
}

- (void)loadDataIntoBucket:(MAVEMerkleTreeDataEnumerator *)enumerator {
    NSMutableArray *dataBucketTmp = [[NSMutableArray alloc] init];
    NSUInteger nextKey;
    while (true) {
        // At end of enumeration, the object is nil
        if (![enumerator peekAtNextObject]) {
            break;
        }
        nextKey = [enumerator keyForNextObject];
        if (!NSLocationInRange(nextKey, self.dataKeyRange)) {
            break;
        }
        [dataBucketTmp addObject:[enumerator nextObject]];
    }
    self.dataBucket = [[NSArray alloc] initWithArray:dataBucketTmp];
}

- (NSUInteger)treeHeight {
    return 1;  // since it's the leaf of the tree
}

- (NSData *)hashValue {
    if (!_hashValue) {
        _hashValue = [MAVEHashingUtils md5Hash:[self serializedData]];
    }
    return _hashValue;
}

// Serialize the merkle tree node (doesn't include data)
- (NSDictionary *)serializeToJSONObject {
    return @{@"k": [MAVEHashingUtils hexStringFromData:self.hashValue],
    };
}

// Serialize the data bucket to NSData so it can be hashed,
// using the block set from the enumerator.
- (NSArray *)serializeableData {
    NSMutableArray *tmp = [[NSMutableArray alloc]initWithCapacity:[self.dataBucket count]];
    id<MAVEMerkleTreeDataItem>item;
    for (item in self.dataBucket) {
        [tmp addObject:[item merkleTreeSerializableData]];
    }
    return [NSArray arrayWithArray:tmp];
}

- (NSData *)serializedData {
    return [MAVEMerkleTreeUtils JSONSerialize:[self serializeableData]];
}

@end
