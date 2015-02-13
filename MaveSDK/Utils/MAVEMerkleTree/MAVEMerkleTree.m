//
//  MAVEMerkleTree.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import "MAVEMerkleTree.h"
#import "MAVEMerkleTreeProtocols.h"
#import "MAVEMerkleTreeInnerNode.h"
#import "MAVEMerkleTreeLeafNode.h"
#import "MAVEMerkleTreeHashUtils.h"
#import "MAVEMerkleTreeUtils.h"

const NSUInteger MAVEMerkleTreeKeySize = sizeof(NSUIntegerMax);

@implementation MAVEMerkleTree

- (instancetype)initWithHeight:(NSUInteger)height
                     arrayData:(NSArray *)data
                  dataKeyRange:(MAVERange64)dataKeyRange
             hashValueNumBytes:(NSInteger)hashValueNumBytes {
    if (self = [super init]) {
        // Can't figure out why, the protocols header is imported but xcode complains that
        // the following is an undeclared selector. So we sort it the tedious way.
//        NSArray *sortedData = [data sortedArrayUsingSelector:@(merkleTreeDataKey)];
        NSArray *sortedData = [data sortedArrayUsingComparator:^NSComparisonResult(id<MAVEMerkleTreeDataItem> obj1, id<MAVEMerkleTreeDataItem> obj2) {
            uint64_t key1 = [obj1 merkleTreeDataKey];
            uint64_t key2 = [obj2 merkleTreeDataKey];
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
                                             withKeyRange:dataKeyRange
                                           dataEnumerator:enumer
                                        hashValueNumBytes:hashValueNumBytes];
    }
    return self;
}

- (NSUInteger) height {
    return [self.root treeHeight];
}

+ (instancetype)emptyTreeWithHashValueNumBytes:(NSInteger)hashValueNumBytes {
    return [[self alloc] initWithHeight:1 arrayData:@[] dataKeyRange:MAVEMakeRange64(0, 0) hashValueNumBytes:hashValueNumBytes];
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

- (NSArray *)changesetForEmptyTreeToMatchSelf {
    NSUInteger hashNumBytes = [self.root.hashValue length];
    MAVEMerkleTree *emptyTree = [[self class] emptyTreeWithHashValueNumBytes:hashNumBytes];
    return [self changesetForOtherTreeToMatchSelf:emptyTree];
}


- (NSDictionary *)serializable {
    NSNumber *height = [NSNumber numberWithInteger:[self.root treeHeight]];
    NSDictionary *treeDict = [self.root serializeToJSONObject];
    if (!treeDict) {
#ifdef DEBUG
        NSLog(@"MAVEMerkleTree - could not JSON serialize tree");
#endif
        return nil;
    }
    return @{@"height": height, @"full_tree": treeDict, @"number_of_records": @0};
}


// Constructor methods for the tree
+ (id<MAVEMerkleTreeNode>)buildMerkleTreeOfHeight:(NSUInteger)height
                                     withKeyRange:(MAVERange64)range
                                   dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator
                                hashValueNumBytes:(NSUInteger)hashValueNumBytes {
    if (height > 1) {
        MAVERange64 lowerHalfRange, upperHalfRange;
        BOOL rangeOK = [self splitRange:range
                              lowerHalf:&lowerHalfRange
                              upperHalf:&upperHalfRange];
        if (!rangeOK) {
            return nil;
        }
        return [[MAVEMerkleTreeInnerNode alloc]
                initWithLeftChild:[self buildMerkleTreeOfHeight:height - 1
                                                   withKeyRange:lowerHalfRange
                                                 dataEnumerator:enumerator
                                              hashValueNumBytes:hashValueNumBytes]
                rightChild:[self buildMerkleTreeOfHeight:height - 1
                                            withKeyRange:upperHalfRange
                                          dataEnumerator:enumerator
                                       hashValueNumBytes:hashValueNumBytes]];
    } else {
        return [[MAVEMerkleTreeLeafNode alloc]
                initWithRange:range
                dataEnumerator:enumerator
                hashValueNumBytes:hashValueNumBytes];
    }
}

//+ (id<MAVEMerkleTreeNode>)buildMerkleTreeOfHeight:(NSUInteger)height
//                                     withKeyRange:(NSRange)range
//                                   dataEnumerator:(MAVEMerkleTreeDataEnumerator *)enumerator {
//    return nil;
//}

+ (id<MAVEMerkleTreeNode>)buildMerkleTreeFromJSONObject:(NSDictionary *)jsonObject {
    NSString *currentKeyHexString = [jsonObject objectForKey:@"k"];

    // tree is balanced so check one child to see if this node is the leaf
    BOOL isLeaf = ![jsonObject objectForKey:@"l"];

    if (isLeaf) {
        NSData *hashValue = [MAVEMerkleTreeHashUtils dataFromHexString:currentKeyHexString];
        MAVEMerkleTreeLeafNode *outNode = [[MAVEMerkleTreeLeafNode alloc] initWithHashValue:hashValue];
        hashValue = [outNode hashValue];
        return outNode;
    } else {
        NSDictionary *leftChildJSON = [jsonObject objectForKey:@"l"];
        NSDictionary *rightChildJSON = [jsonObject objectForKey:@"r"];
        id<MAVEMerkleTreeNode>left = [self buildMerkleTreeFromJSONObject:leftChildJSON];
        id<MAVEMerkleTreeNode>right = [self buildMerkleTreeFromJSONObject:rightChildJSON];
        MAVEMerkleTreeInnerNode *outNode = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:left rightChild:right];
        if (currentKeyHexString) {
            [outNode setHashValueWhenBuildingFromJSON:
             [MAVEMerkleTreeHashUtils dataFromHexString:currentKeyHexString]];
        }
        return outNode;
    }
}

+ (NSArray *)changesetReferenceSubtree:(id<MAVEMerkleTreeNode>)referenceTree
                 matchedByOtherSubtree:(id<MAVEMerkleTreeNode>)otherTree
                     currentPathToNode:(MAVEMerkleTreePath)currentPath {
    NSData *refHash = [referenceTree hashValue];
    if ([refHash isEqualToData:[otherTree hashValue]]) {
        return @[];
    }

    // If we're at the leaf node, build the changeset tuple
    if ([referenceTree treeHeight] == 1) {
        MAVEMerkleTreeLeafNode *referenceLeaf = referenceTree;
        NSArray *rangeLowHigh = @[@(referenceLeaf.dataKeyRange.location),
                                  @(referenceLeaf.dataKeyRange.location - 1 + referenceLeaf.dataKeyRange.length)];
        return @[@[@(currentPath), rangeLowHigh, [MAVEMerkleTreeHashUtils hexStringFromData:refHash], [referenceLeaf serializeableData]]];
    }

    // Otherwise, progress further down the tree to the left and right
    MAVEMerkleTreeInnerNode *referenceNode = referenceTree;
    MAVEMerkleTreeInnerNode *otherNode = otherTree;

    MAVEMerkleTreePath leftPath = currentPath << 1;
    MAVEMerkleTreePath rightPath = (currentPath << 1) | 1;

    // if other tree is shorter than ours, don't traverse it further
    // use a dummy node instead
    id<MAVEMerkleTreeNode> otherLeft;
    id<MAVEMerkleTreeNode> otherRight;
    MAVEMerkleTreeLeafNode *tmpLeaf;
    if ([otherNode treeHeight] == 1) {
        tmpLeaf = [[MAVEMerkleTreeLeafNode alloc] init];
        tmpLeaf.hashValueNumBytes = [refHash length];
        otherLeft = tmpLeaf;
        tmpLeaf = [[MAVEMerkleTreeLeafNode alloc] init];
        tmpLeaf.hashValueNumBytes = [refHash length];
        otherRight = tmpLeaf;
    } else {
        otherLeft = otherNode.leftChild;
        otherRight = otherNode.rightChild;
    }

    NSArray *leftBranchDiffs = [self changesetReferenceSubtree:referenceNode.leftChild matchedByOtherSubtree:otherLeft currentPathToNode:leftPath];
    NSArray *rightBranchDiffs = [self changesetReferenceSubtree:referenceNode.rightChild matchedByOtherSubtree:otherRight currentPathToNode:rightPath];

    // Then concat the the subtrees' changesets to form this node (an inner node) changeset
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:[leftBranchDiffs count] + [rightBranchDiffs count]];
    for (id item in leftBranchDiffs) {
        [tmp addObject:item];
    }
    for (id item in rightBranchDiffs) {
        [tmp addObject:item];
    }
    return [NSArray arrayWithArray:tmp];
}


+ (BOOL)splitRange:(MAVERange64)range
         lowerHalf:(MAVERange64 *)lowerRange
         upperHalf:(MAVERange64 *)upperRange {
    // make sure length isn't too short to be split
    if (range.length == 0 || range.length == 1) {
#ifdef DEBUG
        NSLog(@"MAVEMerkleTree error building tree - range %@ has length %llu",
              NSStringFromMAVERange64(range), range.length);
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
              NSStringFromMAVERange64(range));
#endif
        return NO;
    }

    // Fill in the ranges to return
    *lowerRange = MAVEMakeRange64(range.location, halfLength);
    *upperRange = MAVEMakeRange64(range.location + halfLength, halfLength);
    return YES;
}

@end
