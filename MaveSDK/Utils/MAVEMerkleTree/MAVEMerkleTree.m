//
//  MAVEMerkleTree.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import "MAVEMerkleTree.h"
#import "MAVEMerkleTreeInnerNode.h"
#import "MAVEMerkleTreeLeafNode.h"
#import "MAVEHashingUtils.h"
#import "MAVEMerkleTreeUtils.h"

const NSUInteger MAVEMerkleTreeKeySize = sizeof(NSUIntegerMax);

@implementation MAVEMerkleTree

- (instancetype)initWithHeight:(NSUInteger)height
                     arrayData:(NSArray *)data {
    if (self = [super init]) {
        NSArray *sortedData = [data sortedArrayUsingComparator:^NSComparisonResult(id<MAVEMerkleTreeDataItem> obj1, id<MAVEMerkleTreeDataItem> obj2) {
            NSUInteger key1 = [obj1 merkleTreeDataKey];
            NSUInteger key2 = [obj2 merkleTreeDataKey];
            if (key1 > key2) {
                return NSOrderedDescending;
            } else if (key1 == key2) {
                return NSOrderedSame;
            } else {
                return NSOrderedAscending;
            }
        }];
        MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc]
                                                initWithEnumerator:[sortedData objectEnumerator]];

        self.root = [[self class] buildMerkleTreeOfHeight:height
                                             withKeyRange:NSMakeRange(0, NSUIntegerMax)
                                           dataEnumerator:enumer];
    }
    return self;
}

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject {
    if (self = [super init]) {
        self.root = [[self class] buildMerkleTreeFromJSONObject:jsonObject];
    }
    return self;
}


- (NSArray *)changesetForOtherTreeToMatchSelf:(MAVEMerkleTree *)otherTree {
    NSArray *changeset = [[self class] changesetReferenceSubtree:self.root matchedByOtherSubtree:otherTree.root currentPathToNode:0];
    return  changeset;
}

- (NSDictionary *)serializable {
    NSDictionary *treeObject = [self.root serializeToJSONObject];
    if (!treeObject) {
#ifdef DEBUG
        NSLog(@"MAVEMerkleTree - could not JSON serialize tree");
#endif
        return nil;
    }
    return treeObject;
}

// Constructor methods for the tree
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

+ (id<MAVEMerkleTreeNode>)buildMerkleTreeFromJSONObject:(NSDictionary *)jsonObject {
    // if no key, replace with a zero value node
    NSDictionary *object = [[NSDictionary alloc] initWithDictionary:jsonObject];
    if (![jsonObject objectForKey:@"k"]) {
        uint64_t zero = 0;
        NSString *key = [MAVEHashingUtils hexStringFromData:[NSData dataWithBytes:&zero length:8]];
        object = @{@"k": key};
    }

    // tree is balanced so check one child to see if this node is the leaf
    BOOL isLeaf = ![object objectForKey:@"l"];

    if (isLeaf) {
        NSData *hashValue = [MAVEHashingUtils dataFromHexString:[object objectForKey:@"k"]];
        return [[MAVEMerkleTreeLeafNode alloc] initWithHashValue:hashValue];
    } else {
        NSDictionary *leftChildJSON = [object objectForKey:@"l"];
        NSDictionary *rightChildJSON = [object objectForKey:@"r"];
        id<MAVEMerkleTreeNode>left = [self buildMerkleTreeFromJSONObject:leftChildJSON];
        id<MAVEMerkleTreeNode>right = [self buildMerkleTreeFromJSONObject:rightChildJSON];
        return [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:left rightChild:right];
    }
}

+ (NSArray *)changesetReferenceSubtree:(id<MAVEMerkleTreeNode>)referenceTree
                 matchedByOtherSubtree:(id<MAVEMerkleTreeNode>)otherTree
                     currentPathToNode:(MAVEMerkleTreePath)currentPath {
    NSData *refHash = [referenceTree hashValue];
    if ([refHash isEqualToData:[otherTree hashValue]]) {
        return @[];
    }

    if ([referenceTree treeHeight] == 1) {
        MAVEMerkleTreeLeafNode *referenceLeaf = referenceTree;
        return @[@[@(currentPath), [MAVEHashingUtils hexStringFromData:refHash], [referenceLeaf serializeableData]]];
    }
    MAVEMerkleTreeInnerNode *referenceNode = referenceTree;
    MAVEMerkleTreeInnerNode *otherNode = otherTree;

    MAVEMerkleTreePath leftPath = currentPath << 1;
    MAVEMerkleTreePath rightPath = (currentPath << 1) | 1;

    // if other tree is shorter than ours, don't traverse it further
    // use a dummy node instead
    id<MAVEMerkleTreeNode> otherLeft;
    id<MAVEMerkleTreeNode> otherRight;
    if ([otherNode treeHeight] == 1) {
        otherLeft = [[MAVEMerkleTreeLeafNode alloc] init];
        otherRight = [[MAVEMerkleTreeLeafNode alloc] init];
    } else {
        otherLeft = otherNode.leftChild;
        otherRight = otherNode.rightChild;
    }

    NSArray *leftBranchDiffs = [self changesetReferenceSubtree:referenceNode.leftChild matchedByOtherSubtree:otherLeft currentPathToNode:leftPath];
    NSArray *rightBranchDiffs = [self changesetReferenceSubtree:referenceNode.rightChild matchedByOtherSubtree:otherRight currentPathToNode:rightPath];

    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:[leftBranchDiffs count] + [rightBranchDiffs count]];
    NSUInteger i = 0; id item;
    for (item in leftBranchDiffs) {
        [tmp addObject:item];
        ++i;
    }
    for (item in rightBranchDiffs) {
        [tmp addObject:item];
        ++i;
    }
    return [NSArray arrayWithArray:tmp];
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
