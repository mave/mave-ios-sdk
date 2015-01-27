//
//  MAVEMerkleTree.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import "MAVEMerkleTree.h"
#import "MAVEMerkleTreeNode.h"
#import "MAVEMerkleTreeLeafNode.h"

const NSUInteger MAVEMerkleTreeKeySize = sizeof(uint32_t);

@implementation MAVEMerkleTree

+ (id<MAVEMerkleTreeNode>)buildMerkleTreeOfHeight:(NSUInteger)height
                                     withKeyRange:(NSRange)range
                                   dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator {
    if (height > 1) {
        NSRange lowerHalfRange, upperHalfRange;
        BOOL rangeOK = [self splitRange:range
                              lowerHalf:&lowerHalfRange
                              upperHalf:&upperHalfRange];
        if (!rangeOK) {
            return nil;
        }
        return [[MAVEMerkleTreeInnerNode alloc]
                initWithLeftChild:[self buildMerkleTreeOfHeight:height - 1
                                                   withKeyRange:lowerHalfRange
                                                 dataEnumerator:enumerator]
                rightChild:[self buildMerkleTreeOfHeight:height - 1
                                            withKeyRange:upperHalfRange
                                          dataEnumerator:enumerator]];
    } else {
        return [[MAVEMerkleTreeLeafNode alloc]
                initWithRange:range
                dataEnumerator:enumerator];
    }
}

+ (BOOL)splitRange:(NSRange)range
         lowerHalf:(NSRange *)lowerRange
         upperHalf:(NSRange *)upperRange {
    // make sure length isn't too short to be split
    if (range.length == 0 || range.length == 1) {
#ifdef DEBUG
        NSLog(@"MAVEMerkleTree error building tree - range %@ has length %lu",
              NSStringFromRange(range), (unsigned long)range.length);
#endif
        return NO;
    }
    // check that half the length is a power of two (handles edge case where
    // if using a range of the max length UINT64_MAX which is 2^64 - 1, we
    // can still split it in half and proceed as if it were 2^64).
    NSUInteger halfLength = ceil(range.length / 2);
    double powerOfTwo = log2(halfLength);
    if (powerOfTwo != floor(powerOfTwo)) {
#ifdef DEBUG
        NSLog(@"MAVEMerkleTree error building tree - range %@ length not a power of two",
              NSStringFromRange(range));
#endif
        return NO;
    }

    // Fill in the ranges to return
    *lowerRange = NSMakeRange(range.location, halfLength);
    *upperRange = NSMakeRange(range.location + halfLength, halfLength);
    return YES;
}

@end
