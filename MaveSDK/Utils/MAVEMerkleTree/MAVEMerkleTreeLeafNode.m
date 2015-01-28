//
//  MAVEMerkleTreeLeafNode.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import "MAVEMerkleTreeLeafNode.h"

@implementation MAVEMerkleTreeLeafNode {
    NSData *_hashValue;
}

- (instancetype)initWithRange:(NSRange)range
               dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator {
    if (self = [super init]) {
        self.dataKeyRange = range;
        [self loadDataIntoBucket:enumerator];
        self.blockToSerializeDataBucket = enumerator.blockToSerializeDataBucket;
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

- (NSData *)serializeData {
    NSMutableArray *tmp = [[NSMutableArray alloc]initWithCapacity:[self.dataBucket count]];
    id<MAVEMerkleTreeDataItem>item;
    for (item in self.dataBucket) {
        [tmp addObject:[item merkleTreeSerializableData]];
    }
    NSError *err;
    NSArray *tmp2 = [NSArray arrayWithArray:tmp];
    NSData *output = [NSJSONSerialization dataWithJSONObject:tmp2 options:0 error:&err];
    if (err) {
#ifdef DEBUG
        NSLog(@"MAVEMerkleTree - error %@ serializing data bucket",
              err);
#endif
        return nil;
    }
    return output;
}

@end
