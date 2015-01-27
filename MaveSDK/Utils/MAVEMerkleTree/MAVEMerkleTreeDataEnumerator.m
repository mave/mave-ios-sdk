//
//  MAVEMerkleTreeDataIterable.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import "MAVEMerkleTreeDataEnumerator.h"

@implementation MAVEMerkleTreeDataEnumerator

- (instancetype)initWithEnumerator:(NSEnumerator *)enumerator
           blockThatReturnsHashKey:(NSUInteger (^)(id))block {
    if (self = [super init]) {
        self.enumerator = enumerator;
        // prime to be able to peak at the first object
        self._nextObject = [enumerator nextObject];
        self.blockThatReturnsHashKey = block;
    }
    return self;
}

- (id)nextObject {
    id output = self._nextObject;
    self._nextObject = [self.enumerator nextObject];
    return output;
}

- (id)peekAtNextObject {
    return self._nextObject;
}

- (NSUInteger)keyForNextObject {
    return self.blockThatReturnsHashKey([self peekAtNextObject]);
}

@end
