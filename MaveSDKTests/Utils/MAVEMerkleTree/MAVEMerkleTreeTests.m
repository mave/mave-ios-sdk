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
#import "MAVEHashingUtils.h"

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
- (void)testMerkleTreeInitWithHeight {
    NSArray *data = @[];
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] initWithHeight:3 arrayData:data];
    MAVEMerkleTreeInnerNode *node = tree.root;
    XCTAssertNotNil(node);
    XCTAssertEqual(node.treeHeight, 3);
    MAVEMerkleTreeLeafNode *one = ((MAVEMerkleTreeInnerNode *)node.leftChild).leftChild;
    XCTAssertEqualObjects(one.dataBucket, @[]);
    XCTAssertEqual(one.dataKeyRange.location, 0);
    XCTAssertEqual(one.dataKeyRange.length, pow(2, 64-2));
}

- (void)testInitWithArrayDataSortsIt {
    MAVEMerkleTreeDataDemo *o1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:NSUIntegerMax];
    MAVEMerkleTreeDataDemo *o2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:0];
    NSArray *data = @[o1, o2];
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] initWithHeight:2 arrayData:data];
    MAVEMerkleTreeLeafNode *left = ((MAVEMerkleTreeInnerNode *)tree.root).leftChild;
    MAVEMerkleTreeLeafNode *right = ((MAVEMerkleTreeInnerNode *)tree.root).rightChild;

    // passing in unsorted data, it should get bucketed in the tree correctly
    XCTAssertEqualObjects(left.dataBucket, @[o2]);
    XCTAssertEqualObjects(right.dataBucket, @[o1]);
}

// Test init with JSON object
- (void)testMerkleTreeInitWIthJSONobjectHeight2 {
    NSDictionary *obj = @{
      @"k": @"0001",
      @"l": @{
        @"k": @"0002",
      },
      @"r": @{
        @"k":@"0003",
      },
    };
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc]initWithJSONObject:obj];
    XCTAssertEqual([tree.root treeHeight], 2);
    MAVEMerkleTreeInnerNode *root = tree.root;
    MAVEMerkleTreeLeafNode *left = root.leftChild;
    MAVEMerkleTreeLeafNode *right = root.rightChild;
    // hard-coded hash of string "00020003"
    NSString *expectedRootHash = @"1bbddfac44ce3c01b00194f73ea061f2";
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:[root hashValue]], expectedRootHash);
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:[left hashValue]], @"0002");
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:[right hashValue]], @"0003");
}

- (void)testMerkleTreeInitWithEmptyJSON {
    // So we don't have to check for nil values everywhere, make initializing
    // a node with an object without a key equivalent to using an object with
    // a zero-value hash key
    uint64_t zero = 0;
    NSData *zeroData = [NSData dataWithBytes:&zero length:8];
    NSString *zeroString = [MAVEHashingUtils hexStringFromData:zeroData];
    XCTAssertEqualObjects(zeroString, @"0000000000000000");

    MAVEMerkleTree *tree1 = [[MAVEMerkleTree alloc] initWithJSONObject:@{}];
    XCTAssertEqualObjects([tree1.root hashValue], zeroData);
    MAVEMerkleTree *tree2 = [[MAVEMerkleTree alloc] initWithJSONObject:nil];
    XCTAssertEqualObjects([tree2.root hashValue], zeroData);
}

#pragma mark - Serialization methods
- (void)testSerializableSelf {
    MAVEMerkleTree *tree = [[MAVEMerkleTree alloc] init];
    NSData *fooHash = [MAVEHashingUtils md5Hash:[@"foo" dataUsingEncoding:NSUTF8StringEncoding]];
    tree.root = [[MAVEMerkleTreeLeafNode alloc] initWithHashValue:fooHash];

    NSDictionary *value = [tree serializable];
    NSDictionary *expected = @{@"height": @1, @"data":
                                   @{@"k": [MAVEHashingUtils hexStringFromData:fooHash]}};
    XCTAssertEqualObjects(value, expected);
}

- (void)testChangesetHeight1Tree {
    MAVEMerkleTreeDataDemo *obj1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:10];
    MAVEMerkleTreeDataDemo *obj2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:20];
    MAVEMerkleTreeLeafNode *node1 = [[MAVEMerkleTreeLeafNode alloc] init];
    MAVEMerkleTreeLeafNode *node2 = [[MAVEMerkleTreeLeafNode alloc] init];
    node1.dataBucket = @[obj1];
    node2.dataBucket = @[obj2];
    NSString *node1HashHex = [MAVEHashingUtils hexStringFromData:[node1 hashValue]];
    NSString *node2HashHex = [MAVEHashingUtils hexStringFromData:[node2 hashValue]];

    // When they're the same
    NSArray *diff1 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node1 currentPathToNode:100];
    XCTAssertEqualObjects(diff1, @[]);

    // When different
    NSArray *diff2 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node2 currentPathToNode:100];
    NSArray *expected2 = @[@[@(100), node1HashHex, [node1 serializeableData]]];
    XCTAssertEqualObjects(diff2, expected2);
    // reverse order
    diff2 = [MAVEMerkleTree changesetReferenceSubtree:node2 matchedByOtherSubtree:node1 currentPathToNode:100];
    expected2 = @[@[@(100), node2HashHex, [node2 serializeableData]]];
    XCTAssertEqualObjects(diff2, expected2);
}

- (void)testChangesetsBetweenHeight2Trees {
    MAVEMerkleTreeDataDemo *obj1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:10];
    MAVEMerkleTreeDataDemo *obj2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:20];
    NSString *obj1HashHex = @"2a30f5f3b7d1a97cb6132480b992d984";
    NSString *obj2HashHex = @"baa9a061c77c119b99e6a82b1e741fdc";

    MAVEMerkleTreeLeafNode *left = [[MAVEMerkleTreeLeafNode alloc] init];
    left.dataBucket = @[obj1];
    MAVEMerkleTreeLeafNode *right = [[MAVEMerkleTreeLeafNode alloc] init];
    right.dataBucket = @[obj2];


    MAVEMerkleTreeInnerNode *node1 = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:left rightChild:right];
    MAVEMerkleTreeInnerNode *node2 = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:left rightChild:left];
    MAVEMerkleTreeInnerNode *node3 = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:right rightChild:right];

    // Same trees
    NSArray *diff1 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node1 currentPathToNode:0];
    XCTAssertEqualObjects(diff1, @[]);

    // Right child different
    NSArray *diff2 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node2 currentPathToNode:0];
    NSArray *expected2 = @[@[@(1), obj2HashHex, @[@20]]];
    XCTAssertEqualObjects(diff2, expected2);
    // reverse order
    diff2 = [MAVEMerkleTree changesetReferenceSubtree:node2 matchedByOtherSubtree:node1 currentPathToNode:0];
    expected2 = @[@[@(1), obj1HashHex, @[@10]]];
    XCTAssertEqualObjects(diff2, expected2);
    // Test the tree instance method
    MAVEMerkleTree *tree1 = [[MAVEMerkleTree alloc] init];
    MAVEMerkleTree *tree2 = [[MAVEMerkleTree alloc] init];
    tree1.root = node1; tree2.root = node2;
    diff2 = [tree1 changesetForOtherTreeToMatchSelf:tree2];
    expected2 = @[@[@(1), obj2HashHex, @[@20]]];
    XCTAssertEqualObjects(diff2, expected2);
    // reverse
    diff2 = [tree2 changesetForOtherTreeToMatchSelf:tree1];
    expected2 = @[@[@(1), obj1HashHex, @[@10]]];
    XCTAssertEqualObjects(diff2, expected2);

    // Left child different
    NSArray *diff3 = [MAVEMerkleTree changesetReferenceSubtree:node1 matchedByOtherSubtree:node3 currentPathToNode:0];
    NSArray *expected3 = @[@[@(0), obj1HashHex, @[@10]]];
    XCTAssertEqualObjects(diff3, expected3);
    // reverse order
    diff3 = [MAVEMerkleTree changesetReferenceSubtree:node3 matchedByOtherSubtree:node1 currentPathToNode:0];
    expected3 = @[@[@(0), obj2HashHex, @[@20]]];
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
    node2.dataBucket = @[obj2];
    NSString *node1HashHex = [MAVEHashingUtils hexStringFromData:[node1 hashValue]];
    NSString *node2HashHex = [MAVEHashingUtils hexStringFromData:[node2 hashValue]];
    MAVEMerkleTreeInnerNode *tree1 = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:node1 rightChild:node2];

    MAVEMerkleTreeLeafNode *shortTree = [[MAVEMerkleTreeLeafNode alloc] init];
    shortTree.dataBucket = @[obj3];
    NSString *node3HashHex = [MAVEHashingUtils hexStringFromData:[shortTree hashValue]];

    // Try it where other node is shorter than reference node
    NSArray *diff = [MAVEMerkleTree changesetReferenceSubtree:tree1 matchedByOtherSubtree:shortTree currentPathToNode:0];
    NSArray *expectedDiff = @[
                              @[@(0), node1HashHex, @[@10]],
                              @[@(1), node2HashHex, @[@20]],
    ];
    XCTAssertEqualObjects(diff, expectedDiff);

    // Also try where reference node is shorter than other
    NSArray *diff2 = [MAVEMerkleTree changesetReferenceSubtree:shortTree matchedByOtherSubtree:tree1 currentPathToNode:0];
    NSArray *expectedDiff2 = @[@[@(0), node3HashHex, @[@30]]];
    XCTAssertEqualObjects(diff2, expectedDiff2);
}

// split a range that's a power of 2
- (void)testSplitRangeHelperFunction {
    NSRange range = NSMakeRange(0, 4);
    NSRange leftRange, rightRange;
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
    NSRange newLeftRange2, newRightRange2;
    NSRange newRange = NSMakeRange(0, UINT64_MAX);
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
    NSRange range = NSMakeRange(4, 0);
    BOOL ok = [MAVEMerkleTree splitRange:range
                               lowerHalf:nil
                               upperHalf:nil];
    XCTAssertFalse(ok);
    range = NSMakeRange(0, 1);
    ok = [MAVEMerkleTree splitRange:range
                          lowerHalf:nil
                          upperHalf:nil];
    XCTAssertFalse(ok);

    // won't split a non power of 2 or power of 2 -1 length range
    range = NSMakeRange(0, 6);
    ok = [MAVEMerkleTree splitRange:range
                          lowerHalf:nil
                          upperHalf:nil];
    XCTAssertFalse(ok);

}

- (void)testBuildMerkleTreeWithInnerAndRoot {
    NSRange range = NSMakeRange(0, 8);
    MAVEMerkleTreeDataDemo *o1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:0];
    MAVEMerkleTreeDataDemo *o2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:1];
    MAVEMerkleTreeDataDemo *o3 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:2];
    MAVEMerkleTreeDataDemo *o4 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:4];
    MAVEMerkleTreeDataDemo *o5 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:6];
    NSArray *array = @[o1, o2, o3, o4, o5];

    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[array objectEnumerator]];

    MAVEMerkleTreeInnerNode *root = [MAVEMerkleTree buildMerkleTreeOfHeight:3 withKeyRange:range dataEnumerator:enumer];

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
    NSRange range = NSMakeRange(0, UINT64_MAX);
    MAVEMerkleTreeDataDemo *o1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:0];
    MAVEMerkleTreeDataDemo *o2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:UINT64_MAX];
    NSArray *array = @[o1, o2];

    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[array objectEnumerator]];

    MAVEMerkleTreeInnerNode *root = [MAVEMerkleTree buildMerkleTreeOfHeight:11 withKeyRange:range dataEnumerator:enumer];
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
