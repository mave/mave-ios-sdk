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
#import "MAVEMerkleTreeNode.h"
#import "MAVEHashingUtils.h"

@interface MAVEMerkleTreeNodeTests : XCTestCase

@end

@implementation MAVEMerkleTreeNodeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Merkle Tree


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

    // test against the hard-coded hash of string "ab"
    XCTAssertEqualObjects([MAVEHashingUtils hexStringValue:hash],
                          @"187ef4436122d1cc2f40dc2b92f0eba0");
    OCMVerifyAll(left);
    OCMVerifyAll(right);
}

- (void)testLeafNodeHashValue {
    NSData *data = [@"ab" dataUsingEncoding:NSUTF8StringEncoding];

    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] initWithData:data];
    XCTAssertEqualObjects(node.data, data);

    NSData *hash = [node hashValue];

    // test against the hard-coded hash of string "ab"
    XCTAssertEqualObjects([MAVEHashingUtils hexStringValue:hash],
                          @"187ef4436122d1cc2f40dc2b92f0eba0");
}

- (void)testSingleLeafNodeSerialize {
    NSData *data = [@"a" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    NSString *base64DataString = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(base64DataString, @"YQ==");

    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] initWithData:data];

    NSDictionary *expected = @{@"k": @"0cc175b9c0f1b6a831c399e269772661",
                               @"d": base64DataString};
    NSDictionary *serialized = [node serializeToJSONObject];
    XCTAssertEqualObjects(serialized, expected);
}

- (void)testSerializeTreeOfHeight1 {
    NSData *leftData = [@"a" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *rightData = [@"b" dataUsingEncoding:NSUTF8StringEncoding];
    MAVEMerkleTreeLeafNode *left = [[MAVEMerkleTreeLeafNode alloc] initWithData:leftData];
    MAVEMerkleTreeLeafNode *right = [[MAVEMerkleTreeLeafNode alloc] initWithData:rightData];
    MAVEMerkleTreeInnerNode *node = [[MAVEMerkleTreeInnerNode alloc] initWithLeftChild:left rightChild:right];

    NSDictionary *serialized = [node serializeToJSONObject];



    // test against the hard-coded hash of string "ab"
    NSDictionary *expected = @{@"k": [MAVEHashingUtils hexStringValue:node.hashValue],
                               @"l": [left serializeToJSONObject],
                               @"r": [right serializeToJSONObject],
                               };

    XCTAssertEqualObjects(serialized, expected);
}

@end
