//
//  MAVEMerkleTreeDataDemo.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/27/15.
//
//

#import "MAVEMerkleTreeDataDemo.h"

@implementation MAVEMerkleTreeDataDemo

- (instancetype)initWithValue:(NSUInteger)value {
    if (self = [super init]) {
        self.value = value;
    }
    return self;
}

- (id)merkleTreeSerializableData {
    return @(self.value);
}

- (NSUInteger)merkleTreeDataKey {
    return self.value;
}

@end