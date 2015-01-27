//
//  MAVEMerkleTreeNode.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import "MAVEMerkleTreeNode.h"
#import "MAVEHashingUtils.h"

NSString * const MAVEMerkleTreeKeyVal = @"k";
NSString * const MAVEMerkleTreeLeftChildVal = @"l";
NSString * const MAVEMerkleTreeRightChildVal = @"r";
NSString * const MAVEMerkleTreeDataVal = @"d";


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

- (NSUInteger)treeHeight {
    // since tree is always fixed size and full/balanced, we can take left height and that's tree height
    return [self.leftChild treeHeight] + 1 ;
}

- (NSData *)hashValue {
    if (!_hashValue) {
        NSMutableData *data = [[self.leftChild hashValue] mutableCopy];
        [data appendData:[self.rightChild hashValue]];
        _hashValue = [MAVEHashingUtils md5Hash:data];
    }
    return _hashValue;
}


- (NSDictionary *)serializeToJSONObject {
    NSString *hashString = [MAVEHashingUtils hexStringValue:self.hashValue];
    NSDictionary *leftSerialized = [self.leftChild serializeToJSONObject];
    NSDictionary *rightSerialized = [self.rightChild serializeToJSONObject];
    return @{MAVEMerkleTreeKeyVal: hashString,
             MAVEMerkleTreeLeftChildVal: leftSerialized,
             MAVEMerkleTreeRightChildVal: rightSerialized,
             };
}

@end