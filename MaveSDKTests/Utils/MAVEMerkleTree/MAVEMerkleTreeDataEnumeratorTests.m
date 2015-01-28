//
//  MAVEMerkleTreeDataEnumerator.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/26/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEMerkleTreeDataEnumerator.h"
#import "MAVEMerkleTreeDataDemo.h"

@interface MAVEMerkleTreeDataEnumeratorTests : XCTestCase

@end

@implementation MAVEMerkleTreeDataEnumeratorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitAndIterate {
    MAVEMerkleTreeDataDemo *d1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:1];
    MAVEMerkleTreeDataDemo *d2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:2];
    MAVEMerkleTreeDataDemo *d3 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:3];
    NSArray *data = @[d1, d2, d3];

    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[data objectEnumerator]];

    XCTAssertEqualObjects([enumer nextObject], d1);
    XCTAssertEqualObjects([enumer nextObject], d2);
    XCTAssertEqualObjects([enumer nextObject], d3);
    XCTAssertEqualObjects([enumer nextObject], nil);
}

- (void)testPeek {
    MAVEMerkleTreeDataDemo *d1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:1];
    MAVEMerkleTreeDataDemo *d2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:2];
    MAVEMerkleTreeDataDemo *d3 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:3];
    NSArray *data = @[d1, d2, d3];

    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[data objectEnumerator]];

    // can peak multiple times
    XCTAssertEqualObjects([enumer peekAtNextObject], d1);
    XCTAssertEqualObjects([enumer peekAtNextObject], d1);
    XCTAssertEqualObjects([enumer peekAtNextObject], d1);
    [enumer nextObject];
    XCTAssertEqualObjects([enumer peekAtNextObject], d2);
    [enumer nextObject];
    XCTAssertEqualObjects([enumer peekAtNextObject], d3);
    [enumer nextObject];
    XCTAssertEqualObjects([enumer peekAtNextObject], nil);
}

- (void)testKeyForNextObject {
    MAVEMerkleTreeDataDemo *d1 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:1];
    MAVEMerkleTreeDataDemo *d2 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:2];
    MAVEMerkleTreeDataDemo *d3 = [[MAVEMerkleTreeDataDemo alloc] initWithValue:3];
    NSArray *data = @[d1, d2, d3];

    MAVEMerkleTreeDataEnumerator *enumer = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[data objectEnumerator]];

    XCTAssertEqual([enumer keyForNextObject], 1);
    XCTAssertEqualObjects([enumer nextObject], d1);
}

@end
