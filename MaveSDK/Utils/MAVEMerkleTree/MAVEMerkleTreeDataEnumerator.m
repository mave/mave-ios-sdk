//
//  MAVEMerkleTreeDataIterable.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import "MAVEMerkleTreeDataEnumerator.h"
#import "MAVEMerkleTree.h"

@implementation MAVEMerkleTreeDataEnumerator

- (instancetype)initWithEnumerator:(NSEnumerator *)enumerator {
    if (self = [super init]) {
        self.enumerator = enumerator;
        self._nextObject = [enumerator nextObject];
    }
    return self;
}

- (id<MAVEMerkleTreeDataItem>)nextObject {
    id output = self._nextObject;
    self._nextObject = [self.enumerator nextObject];
    return output;
}

- (id<MAVEMerkleTreeDataItem>)peekAtNextObject {
    return self._nextObject;
}

- (uint64_t)keyForNextObject {
    return [[self peekAtNextObject] merkleTreeDataKey];
}

@end
