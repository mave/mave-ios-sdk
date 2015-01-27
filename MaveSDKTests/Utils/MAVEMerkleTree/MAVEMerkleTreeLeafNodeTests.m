//
//  MAVEMerkleTreeLeafNodeTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEMerkleTreeLeafNode.h"
#import "MAVEMerkleTreeDataEnumerator.h"

@interface MAVEMerkleTreeLeafNodeTests : XCTestCase

@end

@implementation MAVEMerkleTreeLeafNodeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitAndLoadDataIntoBucket {
    NSArray *data = @[@2, @3, @5, @6];
    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[data objectEnumerator] blockThatReturnsHashKey:^NSUInteger(id object) {
        return [((NSNumber *)object) unsignedIntValue];
    }];
    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] initWithRange:NSMakeRange(2, 3+1) dataEnumerator:enumer blockToSerializeDataBucket:nil];

    NSArray *expectedData = @[@2, @3, @5];
    XCTAssertEqualObjects(node.dataBucket, expectedData);
}

@end
