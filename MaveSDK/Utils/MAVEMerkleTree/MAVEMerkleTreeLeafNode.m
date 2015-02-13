//
//  MAVEMerkleTreeLeafNode.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import "MAVEMerkleTreeLeafNode.h"
#import "MAVEMerkleTreeUtils.h"
#import "MAVEMerkleTreeHashUtils.h"

@implementation MAVEMerkleTreeLeafNode {
    NSData *_hashValue;
}

- (instancetype)init {
    if (self = [super init]) {
        // use full 16 bytes of md5 by default
        self.hashValueNumBytes = 16;
    }
    return self;
}

- (instancetype)initWithRange:(MAVERange64*)range
               dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator
            hashValueNumBytes:(NSInteger)hashValueNumBytes
{
    if (self = [super init]) {
        self.dataKeyRange = range;
        self.hashValueNumBytes = hashValueNumBytes;
        [self loadDataIntoBucket:enumerator];
    }
    return self;
}

- (instancetype)initWithHashValue:(NSData *)hashValue {
    if (self = [super init]) {
        _hashValue = hashValue;
        self.hashValueNumBytes = self.hashValue.length;
    }
    return self;
}

- (void)loadDataIntoBucket:(MAVEMerkleTreeDataEnumerator *)enumerator {
    NSMutableArray *dataBucketTmp = [[NSMutableArray alloc] init];
    uint64_t nextKey;
    while (true) {
        // At end of enumeration, the object is nil
        if (![enumerator peekAtNextObject]) {
            break;
        }
        nextKey = [enumerator keyForNextObject];
        if (!MAVELocationInRange64(nextKey, self.dataKeyRange)) {
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
        NSData *fullHashValue = [MAVEMerkleTreeHashUtils md5Hash:[self serializedData]];
        _hashValue = [fullHashValue subdataWithRange:NSMakeRange(0, self.hashValueNumBytes)];
    }
    return _hashValue;
}

// Serialize the merkle tree node (doesn't include data)
- (NSDictionary *)serializeToJSONObject {
    return @{@"k": [MAVEMerkleTreeHashUtils hexStringFromData:self.hashValue],
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
