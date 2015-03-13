//
//  MAVEMerkleTreeInnerNode.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import "MAVEMerkleTreeInnerNode.h"
#import "MAVEMerkleTreeHashUtils.h"


@implementation MAVEMerkleTreeInnerNode {
    NSData *_hashValue;
}

- (instancetype)initWithLeftChild:(id<MAVEMerkleTreeNode>)leftChild rightChild:(id<MAVEMerkleTreeNode>)rightChild {
    if (self = [super init]) {
        self.leftChild = leftChild;
        self.rightChild = rightChild;
    }
    return self;
}

- (void)setHashValueWhenBuildingFromJSON:(NSData *)hashValue {
    _hashValue = hashValue;
}

- (NSUInteger)treeHeight {
    // since tree is always fixed size and full/balanced, we can take left height and that's tree height
    return [self.leftChild treeHeight] + 1 ;
}

- (NSData *)hashValue {
    if (!_hashValue) {
        // determine number of bytes of the hash to return based on length of the left child node's hash value
        NSData *leftHashValue = [self.leftChild hashValue];
        NSUInteger hashLengthBytes = [leftHashValue length];

        NSMutableData *data = [leftHashValue mutableCopy];
        [data appendData:[self.rightChild hashValue]];
        NSData *fullHashData = [MAVEMerkleTreeHashUtils md5Hash:data];

        _hashValue = [fullHashData subdataWithRange:NSMakeRange(0, hashLengthBytes)];
    }
    return _hashValue;
}

- (NSDictionary *)serializeToJSONObject {
    return @{@"k": [MAVEMerkleTreeHashUtils hexStringFromData:self.hashValue],
             @"l": [self.leftChild serializeToJSONObject],
             @"r": [self.rightChild serializeToJSONObject],
    };
}

@end
