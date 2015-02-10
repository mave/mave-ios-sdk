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
#import "MAVEMerkleTreeHashUtils.h"
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

- (void)testInitWithHashValue {
    NSData *hashValue = [@"foo" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqual([hashValue length], 3);
    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] initWithHashValue:hashValue];
    XCTAssertEqualObjects(node.hashValue, hashValue);
    XCTAssertEqual(node.hashValueNumBytes, 3);
}

- (void)testSerializeToJSONObject {
    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] init];
    id mock = OCMPartialMock(node);
    OCMExpect([mock hashValue]).andReturn([@"blah" dataUsingEncoding:NSUTF8StringEncoding]);

    NSDictionary *json = [node serializeToJSONObject];
    NSDictionary *expected = @{@"k": @"626c6168"};  // hexcode of "blah"
    XCTAssertEqualObjects(json, expected);
    OCMVerifyAll(mock);
}

- (void)testHashValue16Bytes {
    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] init];
    node.hashValueNumBytes = 16;
    id mock = OCMPartialMock(node);
    OCMExpect([mock serializedData]).andReturn([@"blah" dataUsingEncoding:NSUTF8StringEncoding]);

    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:[node hashValue]],
                          @"6f1ed002ab5595859014ebf0951522d9");
    OCMVerifyAll(mock);
}

- (void)testHashValue1Byte {
    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] init];
    node.hashValueNumBytes = 1;
    id mock = OCMPartialMock(node);
    OCMExpect([mock serializedData]).andReturn([@"blah" dataUsingEncoding:NSUTF8StringEncoding]);

    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:[node hashValue]],
                          @"6f");
    OCMVerifyAll(mock);
}

- (void)testHashValueOfEmptyData {
    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] init];
    node.hashValueNumBytes = 8;
    node.dataBucket = @[];
    // ensure it's equal to hard-coded hash of "[]"
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:[node hashValue]],
                          @"d751713988987e93");
}

- (void)testInitAndLoadData {
    MAVEMerkleTreeDataDemo *d1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:2];
    MAVEMerkleTreeDataDemo *d2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:3];
    MAVEMerkleTreeDataDemo *d3 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:5];
    MAVEMerkleTreeDataDemo *d4 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:6];

    NSArray *data = @[d1, d2, d3, d4];
    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[data objectEnumerator]];

    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] initWithRange:NSMakeRange(2, 3+1) dataEnumerator:enumer hashValueNumBytes:13];
    NSArray *expectedData = @[d1, d2, d3];
    XCTAssertEqualObjects(node.dataBucket, expectedData);
    XCTAssertEqual(node.hashValueNumBytes, 13);
}

// Should call the protocol method to make data items serializable
// and return an array of those
- (void)testSerializableAndSerialzeData {
    // Setup the data and init object
    MAVEMerkleTreeDataDemo *d1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:0];
    MAVEMerkleTreeDataDemo *d2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:2];

    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] init];
    id d1Mock = OCMPartialMock(d1);
    OCMStub([d1Mock merkleTreeSerializableData]).andReturn(@"foo");
    node.dataBucket = @[d1, d2];

    // Serialize the data & check it
    NSArray *expected = @[@"foo", @2];
    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:expected options:0 error:nil];
    XCTAssertNotNil(expectedData);
    NSArray *output = [node serializeableData];
    XCTAssertEqualObjects(output, expected);

    NSData *outputData = [node serializedData];
    XCTAssertEqualObjects(outputData, expectedData);
}

- (void)testSerializeEmptyData {
    MAVEMerkleTreeLeafNode *node = [[MAVEMerkleTreeLeafNode alloc] init];
    node.dataBucket = @[];

    // Serialize the data & check it
    NSArray *expected = @[];
    NSData *expectedData= [NSJSONSerialization dataWithJSONObject:@[] options:0 error:nil];
    XCTAssertNotNil(expectedData);
    NSArray *output = [node serializeableData];
    XCTAssertEqualObjects(output, expected);

    NSData *outputData = [node serializedData];
    XCTAssertEqualObjects(outputData, expectedData);
}

@end
