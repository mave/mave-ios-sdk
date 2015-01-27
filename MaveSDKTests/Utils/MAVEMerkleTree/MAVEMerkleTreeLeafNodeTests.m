//
//  MAVEMerkleTreeLeafNodeTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEMerkleTreeLeafNode.h"
#import "MAVEMerkleTreeDataEnumerator.h"
#import "MAVEMerkleTreeDataDemo.h"

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

- (void)testInitAndLoadData {
    MAVEMerkleTreeDataDemo *d1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:2];
    MAVEMerkleTreeDataDemo *d2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:3];
    MAVEMerkleTreeDataDemo *d3 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:5];
    MAVEMerkleTreeDataDemo *d4 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:6];

    NSArray *data = @[d1, d2, d3, d4];
    NSData *(^serializeBlock)(NSArray *array) = ^NSData *(NSArray *array) {
        return [@"foo" dataUsingEncoding:NSUTF8StringEncoding];
    };
    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[data objectEnumerator] blockToSerializeDataBucket:serializeBlock];

    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] initWithRange:NSMakeRange(2, 3+1) dataEnumerator:enumer];

    XCTAssertEqual(node.blockToSerializeDataBucket, serializeBlock);
    NSArray *expectedData = @[d1, d2, d3];
    XCTAssertEqualObjects(node.dataBucket, expectedData);
}

- (void)testSerializeData {
    // Setup the data and init object
    MAVEMerkleTreeDataDemo *d1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:0];
    MAVEMerkleTreeDataDemo *d2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:2];
    NSData *(^serializeBlock)(NSArray *array) = ^NSData *(NSArray *array) {
        return [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
    };

    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] init];
    id d1Mock = OCMPartialMock(d1);
    OCMStub([d1Mock merkleTreeSerializableData]).andReturn(@"foo");
    node.dataBucket = @[d1, d2];
    node.blockToSerializeDataBucket = serializeBlock;

    // Serialize the data & check it
    NSArray *expectedObj = @[@"foo", @2];
    NSData *expected = [NSJSONSerialization dataWithJSONObject:expectedObj options:0 error:nil];
    XCTAssertNotNil(expected);
    NSData *output = [node serializeData];
    XCTAssertEqualObjects(output, expected);

    NSArray *unpacked = [NSJSONSerialization JSONObjectWithData:output options:0 error:nil];
    XCTAssertEqualObjects(unpacked, expectedObj);
}

- (void)testSerializeEmptyData {
    NSData *(^serializeBlock)(NSArray *array) = ^NSData *(NSArray *array) {
        return [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
    };
    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] init];
    node.dataBucket = @[];
    node.blockToSerializeDataBucket = serializeBlock;

    // Serialize the data & check it
    NSData *expected = [NSJSONSerialization dataWithJSONObject:@[] options:0 error:nil];
    XCTAssertNotNil(expected);
    NSData *output = [node serializeData];
    XCTAssertEqualObjects(output, expected);

    NSArray *unpacked = [NSJSONSerialization JSONObjectWithData:output options:0 error:nil];
    XCTAssertEqualObjects(unpacked, @[]);
}

@end
