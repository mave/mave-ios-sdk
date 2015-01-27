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
               dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator
   blockToSerializeDataBucket:(NSData *(^)(NSArray *))block {
    if (self = [super init]) {
        self.dataKeyRange = range;
        [self loadDataIntoBucket:enumerator];
        self.blockToSerializeDataBucket = block;
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
    // Just a leaf has a tree height of 1
    return 1;
}

@end
