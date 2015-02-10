//
//  MAVEMerkleTreeNodeTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEMerkleTreeInnerNode.h"
#import "MAVEMerkleTreeHashUtils.h"

@interface MAVEMerkleTreeInnerNodeTests : XCTestCase

@end

@implementation MAVEMerkleTreeInnerNodeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

# pragma mark - Merkle Tree Nodes
- (void)testInnerNodeHashValue {
    id left = OCMClassMock([MAVEMerkleTreeInnerNode class]);
    id right = OCMClassMock([MAVEMerkleTreeInnerNode class]);

    MAVEMerkleTreeInnerNode *node = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:left rightChild:right];
    XCTAssertEqualObjects(node.leftChild, left);
    XCTAssertEqualObjects(node.rightChild, right);

    OCMExpect([left hashValue]).andReturn([@"a" dataUsingEncoding:NSUTF8StringEncoding]);
    OCMExpect([right hashValue]).andReturn([@"b" dataUsingEncoding:NSUTF8StringEncoding]);

    NSData *hash = [node hashValue];

    // test against the hard-coded hash of string "ab".
    // Since left child had just a one byte hash value, our hash value will be the same length (1 byte)
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:hash],
                          @"18");
    OCMVerifyAll(left);
    OCMVerifyAll(right);
}

- (void)testSetHashValueWhenBuildingFromJSON {
    MAVEMerkleTreeInnerNode *node = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:nil rightChild:nil];
    [node setHashValueWhenBuildingFromJSON:[MAVEMerkleTreeHashUtils dataFromHexString:@"01"]];
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:[node hashValue]], @"01");
}

- (void)testInnerNodeLongerLeftHashValue {
    // Use length of the left child node hash value to determine correct length of hash value
    // (left and right will always be the same length in a real tree we build)
    id left = OCMClassMock([MAVEMerkleTreeInnerNode class]);
    id right = OCMClassMock([MAVEMerkleTreeInnerNode class]);

    MAVEMerkleTreeInnerNode *node = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:left rightChild:right];
    XCTAssertEqualObjects(node.leftChild, left);
    XCTAssertEqualObjects(node.rightChild, right);

    OCMExpect([left hashValue]).andReturn([@"abcdefgh" dataUsingEncoding:NSUTF8StringEncoding]);
    OCMExpect([right hashValue]).andReturn([@"" dataUsingEncoding:NSUTF8StringEncoding]);

    NSData *hash = [node hashValue];

    // test against the hard-coded hash of string "".
    // Since left child had just a one byte hash value, our hash value will be the same length (1 byte)
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:hash],
                          @"e8dc4081b13434b4");
    OCMVerifyAll(left);
    OCMVerifyAll(right);
}



@end
