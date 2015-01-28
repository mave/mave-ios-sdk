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
#import "MAVEHashingUtils.h"

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

    // test against the hard-coded hash of string "ab"
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:hash],
                          @"187ef4436122d1cc2f40dc2b92f0eba0");
    OCMVerifyAll(left);
    OCMVerifyAll(right);
}



@end
