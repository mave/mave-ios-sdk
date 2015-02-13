//
//  MAVEMerkleTreeTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEMerkleTree.h"
#import "MAVEMerkleTreeInnerNode.h"
#import "MAVEMerkleTreeLeafNode.h"
#import "MAVEMerkleTreeDataEnumerator.h"
#import "MAVEMerkleTreeDataDemo.h"
#import "MAVEMerkleTreeHashUtils.h"

@interface MAVEMerkleTreeTests : XCTestCase

@end

@implementation MAVEMerkleTreeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Test the public initializer functions
- (void)testMerkleTreeInitWithArgs {
    NSArray *data = @[];
    MAVERange64 range = MAVEMakeRange64(1, 8);
    NSUInteger hashValueNumBytes = 4;
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] initWithHeight:3
                                                        arrayData:data
                                                     dataKeyRange:range
                                                hashValueNumBytes:hashValueNumBytes];
    XCTAssertEqual(tree.height, 3);

    MAVEMerkleTreeInnerNode *node = tree.root;
    XCTAssertNotNil(node);
    XCTAssertEqual(node.treeHeight, 3);
    MAVEMerkleTreeLeafNode *one = ((MAVEMerkleTreeInnerNode *)node.leftChild).leftChild;
    XCTAssertEqualObjects(one.dataBucket, @[]);
    // 4 bytes of hash of empty list
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:one.hashValue], @"d7517139");
    XCTAssertEqual(one.hashValueNumBytes, hashValueNumBytes);
    // we've traversed two levels, so leftmost leaf's range length is divided by 2^4
    XCTAssertEqual(one.dataKeyRange.location, 1);
    XCTAssertEqual(one.dataKeyRange.length, 2);
}

- (void)testInitWithArrayDataSortsIt {
    // test initializing with max data range, and that data gets sorted
    MAVEMerkleTreeDataDemo *o1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:NSUIntegerMax];
    MAVEMerkleTreeDataDemo *o2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:0];
    NSArray *data = @[o1, o2];
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] initWithHeight:2 arrayData:data
                                                     dataKeyRange:MAVEMakeRange64(0, UINT64_MAX)
                                                hashValueNumBytes:16];
    MAVEMerkleTreeLeafNode *left = ((MAVEMerkleTreeInnerNode *)tree.root).leftChild;
    MAVEMerkleTreeLeafNode *right = ((MAVEMerkleTreeInnerNode *)tree.root).rightChild;

    // passing in unsorted data, it should get bucketed in the tree correctly
    XCTAssertEqualObjects(left.dataBucket, @[o2]);
    XCTAssertEqualObjects(right.dataBucket, @[o1]);
}

// Test init with JSON object
- (void)testMerkleTreeInitWithJSONobjectHeight2 {
    NSDictionary *obj = @{
      @"k": @"0001",
      @"l": @{
        @"k": @"0002",
      },
      @"r": @{
        @"k":@"0003",
      },
    };
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] initWithJSONObject:obj];
    XCTAssertEqual([tree.root treeHeight], 2);
    MAVEMerkleTreeInnerNode *root = tree.root;
    MAVEMerkleTreeLeafNode *left = root.leftChild;
    MAVEMerkleTreeLeafNode *right = root.rightChild;
    // hard-coded hash of string "00020003"
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:[root hashValue]], @"0001");
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:[left hashValue]], @"0002");
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:[right hashValue]], @"0003");
}

- (void)testMerkleTreeInitWithJSONObjectHeight2InnerNodeMissingKey {
    // If any of the inner nodes don't come with a key in the json data,
    // just recompute it the normal way from the leaf nodes
    NSDictionary *obj = @{
      @"l": @{
        @"k": @"0002",
      },
      @"r": @{
        @"k":@"0003",
      },
    };
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] initWithJSONObject:obj];
    // now root key should be hash of the other two keys
    // (will truncate to the length of its children keys)
    // check against hard-coded value
    XCTAssertEqual([tree.root treeHeight], 2);
    MAVEMerkleTreeInnerNode *root = tree.root;
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:[root hashValue]], @"1bbd");
}

- (void)testMerkleTreeInitWithJSONObjectHeight1 {
    NSDictionary *obj = @{@"k": @"0001"};
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] initWithJSONObject:obj];
    XCTAssertEqual([tree.root treeHeight], 1);
    MAVEMerkleTreeLeafNode *leaf = tree.root;
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:[leaf hashValue]], @"0001");
}

- (void)testMerkleTreeInitWithJSONObjectHeight1NoKey {
    // degenerate case, will just have empty data as the hash value
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] initWithJSONObject:@{}];
    MAVEMerkleTreeLeafNode *leaf = tree.root;
    XCTAssertEqualObjects([leaf hashValue], [@"" dataUsingEncoding:NSUTF8StringEncoding]);
}

#pragma mark - Serialization methods
- (void)testSerializableSelf {
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] init];
    NSData *fooHash = [MAVEMerkleTreeHashUtils md5Hash:[@"foo" dataUsingEncoding:NSUTF8StringEncoding]];
    tree.root = [[MAVEMerkleTreeLeafNode alloc] initWithHashValue:fooHash];

    NSDictionary *value = [tree serializable];
    NSDictionary *expected = @{@"height": @1,
                               @"full_tree":
                                   @{@"k": [MAVEMerkleTreeHashUtils hexStringFromData:fooHash]},
                               @"number_of_records": @0,
                               };
    XCTAssertEqualObjects(value, expected);
}

- (void)testChangesetBaseCaseHeight1Tree {
    MAVEMerkleTreeDataDemo *obj1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:10];
    MAVEMerkleTreeDataDemo *obj2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:20];
    MAVEMerkleTreeLeafNode *node1 = [[MAVEMerkleTreeLeafNode alloc] init];
    MAVEMerkleTreeLeafNode *node2 = [[MAVEMerkleTreeLeafNode alloc] init];
    node1.dataBucket = @[obj1];
    node1.dataKeyRange = MAVEMakeRange64(0, 4);
    node2.dataBucket = @[obj2];
    node2.dataKeyRange = MAVEMakeRange64(4, 4);
    NSString *node1HashHex = [MAVEMerkleTreeHashUtils hexStringFromData:[node1 hashValue]];
    NSString *node2HashHex = [MAVEMerkleTreeHashUtils hexStringFromData:[node2 hashValue]];

    // When they're the same
    NSArray *diff1 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node1 currentPathToNode:100];
    XCTAssertEqualObjects(diff1, @[]);

    // When different
    NSArray *diff2 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node2 currentPathToNode:100];
    NSArray *expected2 = @[@[@(100), @[@0, @3], node1HashHex, [node1 serializeableData]]];
    XCTAssertEqualObjects(diff2, expected2);
    // reverse order
    diff2 = [MAVEMerkleTree changesetReferenceSubtree:node2 matchedByOtherSubtree:node1 currentPathToNode:100];
    expected2 = @[@[@(100), @[@4, @7], node2HashHex, [node2 serializeableData]]];
    XCTAssertEqualObjects(diff2, expected2);
}

- (void)testChangesetsBetweenHeight2Trees {
    MAVEMerkleTreeDataDemo *obj1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:10];
    MAVEMerkleTreeDataDemo *obj2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:20];
    NSString *obj1HashHex = @"2a30f5f3b7d1a97cb6132480b992d984";
    NSString *obj2HashHex = @"baa9a061c77c119b99e6a82b1e741fdc";

    MAVEMerkleTreeLeafNode *left = [[MAVEMerkleTreeLeafNode alloc] init];
    left.dataBucket = @[obj1];
    left.dataKeyRange = MAVEMakeRange64(0, 1);
    MAVEMerkleTreeLeafNode *right = [[MAVEMerkleTreeLeafNode alloc] init];
    right.dataBucket = @[obj2];
    right.dataKeyRange = MAVEMakeRange64(1, 1);

    MAVEMerkleTreeInnerNode *node1 = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:left rightChild:right];
    MAVEMerkleTreeInnerNode *node2 = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:left rightChild:left];
    MAVEMerkleTreeInnerNode *node3 = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:right rightChild:right];

    // Same trees
    NSArray *diff1 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node1 currentPathToNode:0];
    XCTAssertEqualObjects(diff1, @[]);

    // Right child different
    NSArray *diff2 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node2 currentPathToNode:0];
    NSArray *expected2 = @[@[@(1), @[@1, @1], obj2HashHex, @[@20]]];
    XCTAssertEqualObjects(diff2, expected2);
    // reverse order
    diff2 = [MAVEMerkleTree changesetReferenceSubtree:node2 matchedByOtherSubtree:node1 currentPathToNode:0];
    expected2 = @[@[@(1), @[@0, @0], obj1HashHex, @[@10]]];
    XCTAssertEqualObjects(diff2, expected2);
    // Test the tree instance method
    MAVEMerkleTree *tree1 = [[MAVEMerkleTree alloc] init];
    MAVEMerkleTree *tree2 = [[MAVEMerkleTree alloc] init];
    tree1.root = node1; tree2.root = node2;
    diff2 = [tree1 changesetForOtherTreeToMatchSelf:tree2];
    expected2 = @[@[@(1), @[@1, @1], obj2HashHex, @[@20]]];
    XCTAssertEqualObjects(diff2, expected2);
    // reverse
    diff2 = [tree2 changesetForOtherTreeToMatchSelf:tree1];
    expected2 = @[@[@(1), @[@0, @0], obj1HashHex, @[@10]]];
    XCTAssertEqualObjects(diff2, expected2);

    // Left child different
    NSArray *diff3 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node3 currentPathToNode:0];
    NSArray *expected3 = @[@[@(0), @[@0, @0], obj1HashHex, @[@10]]];
    XCTAssertEqualObjects(diff3, expected3);
    // reverse order
    diff3 = [MAVEMerkleTree changesetReferenceSubtree:node3 matchedByOtherSubtree:node1 currentPathToNode:0];
    expected3 = @[@[@(0), @[@1, @1], obj2HashHex, @[@20]]];
    XCTAssertEqualObjects(diff3, expected3);

    // Test for different starting path height
    NSArray *diff4 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node2 currentPathToNode:8];
    // New path is 8 bitshifted and OR'd with 1
    XCTAssertEqualObjects([[diff4 objectAtIndex:0] objectAtIndex:0], @17);
    NSArray *diff5 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node3 currentPathToNode:8];
    XCTAssertEqualObjects([[diff5 objectAtIndex:0] objectAtIndex:0], @16);
}

- (void)testChangesetAgainstDifferentSizedTree {
    MAVEMerkleTreeDataDemo *obj1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:10];
    MAVEMerkleTreeDataDemo *obj2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:20];
    MAVEMerkleTreeDataDemo *obj3 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:30];
    MAVEMerkleTreeLeafNode *node1 = [[MAVEMerkleTreeLeafNode alloc] init];
    MAVEMerkleTreeLeafNode *node2 = [[MAVEMerkleTreeLeafNode alloc] init];
    node1.dataBucket = @[obj1];
    node1.dataKeyRange = MAVEMakeRange64(0, 1);
    node2.dataBucket = @[obj2];
    node2.dataKeyRange = MAVEMakeRange64(1, 1);
    NSString *node1HashHex = [MAVEMerkleTreeHashUtils hexStringFromData:[node1 hashValue]];
    NSString *node2HashHex = [MAVEMerkleTreeHashUtils hexStringFromData:[node2 hashValue]];
    MAVEMerkleTreeInnerNode *tree1 = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:node1 rightChild:node2];

    MAVEMerkleTreeLeafNode *shortTree = [[MAVEMerkleTreeLeafNode alloc] init];
    shortTree.dataBucket = @[obj3];
    shortTree.dataKeyRange = MAVEMakeRange64(0, 4);
    NSString *node3HashHex = [MAVEMerkleTreeHashUtils hexStringFromData:[shortTree hashValue]];

    // Try it where other node is shorter than reference node
    NSArray *diff = [MAVEMerkleTree changesetReferenceSubtree:tree1 matchedByOtherSubtree:shortTree currentPathToNode:0];
    NSArray *expectedDiff = @[
                              @[@(0), @[@0, @0], node1HashHex, @[@10]],
                              @[@(1), @[@1, @1], node2HashHex, @[@20]],
    ];
    XCTAssertEqualObjects(diff, expectedDiff);

    // Also try where reference node is shorter than other
    NSArray *diff2 = [MAVEMerkleTree changesetReferenceSubtree:shortTree matchedByOtherSubtree:tree1 currentPathToNode:0];
    NSArray *expectedDiff2 = @[@[@(0), @[@0, @3], node3HashHex, @[@30]]];
    XCTAssertEqualObjects(diff2, expectedDiff2);
}

- (void)testChangesetAgainstEmptyTree {
    // start with a tree with 2 leaves, one has data and one empty. The one that's empty should not
    // appear in the changeset against the completely empty tree
    MAVEMerkleTreeDataDemo *obj1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:3];
    MAVERange64 range = MAVEMakeRange64(0, 8);
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] initWithHeight:2 arrayData:@[obj1] dataKeyRange:range hashValueNumBytes:4];
    // double check tree got set up correctly
    MAVEMerkleTreeLeafNode *leftChild = ((MAVEMerkleTreeInnerNode *)tree.root).leftChild;
    MAVEMerkleTreeLeafNode *rightChild = ((MAVEMerkleTreeInnerNode *)tree.root).rightChild;
    XCTAssertEqualObjects(leftChild.dataBucket, @[obj1]);
    XCTAssertEqualObjects(rightChild.dataBucket, @[]);

    // with explicitly build empty tree
    MAVEMerkleTree *emptyTree = [[MAVEMerkleTree alloc]initWithHeight:2 arrayData:@[] dataKeyRange:range hashValueNumBytes:4];

    // add item to make empty tree match tree
    NSArray *diff1 = [tree changesetForOtherTreeToMatchSelf:emptyTree];
    NSArray *expected1 = @[@[@0, @[@0, @3], @"f2577a6f", @[@3]]];
    XCTAssertEqualObjects(diff1, expected1);

    // remove left child items and add none to make tree match empty tree
    NSArray *diff2 = [emptyTree changesetForOtherTreeToMatchSelf:tree];
    NSArray *expected2 = @[@[@0, @[@0, @3], @"d7517139", @[]]];
    XCTAssertEqualObjects(diff2, expected2);

    // also test with helper method for diffing against an empty tree
    XCTAssertEqualObjects([tree changesetForEmptyTreeToMatchSelf], expected1);
}

- (void)testChangesetEmptyTreeAgainstShorterEmptyTree {
    // changeset should be empty, short empty tree getting compared against a tree should look like an
    // empty tree of the appropriate height
    MAVERange64 range = MAVEMakeRange64(0, 8);
    MAVEMerkleTree *emptyTree = [[MAVEMerkleTree alloc] initWithHeight:2 arrayData:@[] dataKeyRange:range hashValueNumBytes:4];

    // Use our helper for creating a standin empty tree that can be compared against
    MAVEMerkleTree *shortEmptyTree = [MAVEMerkleTree emptyTreeWithHashValueNumBytes:4];
    XCTAssertEqual([shortEmptyTree.root treeHeight], 1);
    MAVEMerkleTreeLeafNode *leaf = shortEmptyTree.root;
    XCTAssertEqual(leaf.hashValueNumBytes, 4);
    XCTAssertEqualObjects(leaf.dataBucket, @[]);

    XCTAssertEqualObjects([emptyTree changesetForOtherTreeToMatchSelf:shortEmptyTree], @[]);

    // Also test the even shorter helper method
    XCTAssertEqualObjects([emptyTree changesetForEmptyTreeToMatchSelf], @[]);
}

// split a range that's a power of 2
- (void)testSplitRangeHelperFunction {
    MAVERange64 range = MAVEMakeRange64(0, 4);
    MAVERange64 leftRange, rightRange;
    BOOL ok = [MAVEMerkleTree splitRange:range
                               lowerHalf:&leftRange
                               upperHalf:&rightRange];
    XCTAssertTrue(ok);
    XCTAssertEqual(leftRange.location, 0);
    XCTAssertEqual(leftRange.length, 2);
    XCTAssertEqual(rightRange.location, 2);
    XCTAssertEqual(rightRange.length, 2);

    // Now split one of them again
    NSRange newLeftRange, newRightRange;
    ok = [MAVEMerkleTree splitRange:rightRange
                          lowerHalf:&newLeftRange
                          upperHalf:&newRightRange];
    XCTAssertTrue(ok);
    XCTAssertEqual(newLeftRange.location, 2);
    XCTAssertEqual(newLeftRange.length, 1);
    XCTAssertEqual(newRightRange.location, 3);
    XCTAssertEqual(newRightRange.length, 1);

    // Split the max range
    MAVERange64 newLeftRange2, newRightRange2;
    MAVERange64 newRange = MAVEMakeRange64(0, UINT64_MAX);
    NSUInteger halfSize = pow(2, 63);
    ok = [MAVEMerkleTree splitRange:newRange
                          lowerHalf:&newLeftRange2
                          upperHalf:&newRightRange2];
    XCTAssertTrue(ok);
    XCTAssertEqual(newLeftRange2.location, 0);
    XCTAssertEqual(newLeftRange2.length, halfSize);
    XCTAssertEqual(newRightRange2.location, halfSize);
    XCTAssertEqual(newRightRange2.length, halfSize);
}

- (void)testSplitRangeInvalidValues {
    // can't split length 0 or 1
    MAVERange64 range = MAVEMakeRange64(4, 0);
    BOOL ok = [MAVEMerkleTree splitRange:range
                               lowerHalf:nil
                               upperHalf:nil];
    XCTAssertFalse(ok);
    range = MAVEMakeRange64(0, 1);
    ok = [MAVEMerkleTree splitRange:range
                          lowerHalf:nil
                          upperHalf:nil];
    XCTAssertFalse(ok);

    // won't split a non power of 2 or power of 2 -1 length range
    range = MAVEMakeRange64(0, 6);
    ok = [MAVEMerkleTree splitRange:range
                          lowerHalf:nil
                          upperHalf:nil];
    XCTAssertFalse(ok);

}

- (void)testBuildMerkleTreeWithInnerAndRoot {
    MAVERange64 range = MAVEMakeRange64(0, 8);
    MAVEMerkleTreeDataDemo *o1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:0];
    MAVEMerkleTreeDataDemo *o2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:1];
    MAVEMerkleTreeDataDemo *o3 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:2];
    MAVEMerkleTreeDataDemo *o4 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:4];
    MAVEMerkleTreeDataDemo *o5 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:6];
    NSArray *array = @[o1, o2, o3, o4, o5];

    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[array objectEnumerator]];

    MAVEMerkleTreeInnerNode *root = [MAVEMerkleTree buildMerkleTreeOfHeight:3 withKeyRange:range dataEnumerator:enumer hashValueNumBytes:16];

    XCTAssertEqual(root.treeHeight, 3);
    MAVEMerkleTreeInnerNode *left = root.leftChild;
    MAVEMerkleTreeInnerNode *right = root.rightChild;
    MAVEMerkleTreeLeafNode *first = left.leftChild;
    MAVEMerkleTreeLeafNode *second = left.rightChild;
    MAVEMerkleTreeLeafNode *third = right.leftChild;
    MAVEMerkleTreeLeafNode *fourth = right.rightChild;
    NSArray *expected;

    XCTAssertEqual(first.dataKeyRange.location, 0);
    XCTAssertEqual(first.dataKeyRange.length, 2);
    expected = @[o1, o2];
    XCTAssertEqualObjects(first.dataBucket, expected);

    XCTAssertEqual(second.dataKeyRange.location, 2);
    XCTAssertEqual(second.dataKeyRange.length, 2);
    expected = @[o3];
    XCTAssertEqualObjects(second.dataBucket, expected);

    XCTAssertEqual(third.dataKeyRange.location, 4);
    XCTAssertEqual(third.dataKeyRange.length, 2);
    expected = @[o4];
    XCTAssertEqualObjects(third.dataBucket, expected);

    XCTAssertEqual(fourth.dataKeyRange.location, 6);
    XCTAssertEqual(fourth.dataKeyRange.length, 2);
    expected = @[o5];
    XCTAssertEqualObjects(fourth.dataBucket, expected);
}

- (void)testBuildBigTreeWithMaxRange {
    MAVERange64 range = MAVEMakeRange64(0, UINT64_MAX);
    MAVEMerkleTreeDataDemo *o1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:0];
    MAVEMerkleTreeDataDemo *o2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:UINT64_MAX];
    NSArray *array = @[o1, o2];

    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[array objectEnumerator]];

    MAVEMerkleTreeInnerNode *root = [MAVEMerkleTree buildMerkleTreeOfHeight:11 withKeyRange:range   dataEnumerator:enumer hashValueNumBytes:16];
    XCTAssertEqual(root.treeHeight, 11);
    NSUInteger expectedRangeSize = pow(2, 64 - (11-1));

    // check leftmost node
    MAVEMerkleTreeInnerNode *node = root;
    for (NSInteger i = 1; i < 11 - 1; ++i) {
        node = node.leftChild;
    }
    MAVEMerkleTreeLeafNode *leftLeaf = node.leftChild;
    XCTAssertEqual(leftLeaf.dataKeyRange.location, 0);
    XCTAssertEqual(leftLeaf.dataKeyRange.length, expectedRangeSize);
    XCTAssertEqualObjects(leftLeaf.dataBucket, @[o1]);

    // check rightmost node
    node = root;
    for (NSInteger i = 1; i < 11 - 1; ++i) {
        node = node.rightChild;
    }
    MAVEMerkleTreeLeafNode *rightLeaf = node.rightChild;
    XCTAssertEqual(rightLeaf.dataKeyRange.location, UINT64_MAX - expectedRangeSize + 1);
    XCTAssertEqual(rightLeaf.dataKeyRange.length, expectedRangeSize);
    XCTAssertEqualObjects(rightLeaf.dataBucket, @[o2]);
}



@end
