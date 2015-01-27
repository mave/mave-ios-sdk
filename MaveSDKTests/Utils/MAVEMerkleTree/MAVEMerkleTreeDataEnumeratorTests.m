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
    NSDictionary *d1 = @{@"k": @1, @"v": @"foo1"};
    NSDictionary *d2 = @{@"k": @2, @"v": @"foo2"};
    NSDictionary *d3 = @{@"k": @3, @"v": @"foo3"};
    NSArray *data = @[d1, d2, d3];
    NSUInteger (^blockToReturnKey)(id object) = ^NSUInteger (id object) {
        NSDictionary *dictObject = object;
        return [[dictObject objectForKey:@"k"] unsignedIntValue];
    };

    MAVEMerkleTreeDataEnumerator *iter = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[data objectEnumerator] blockThatReturnsHashKey:blockToReturnKey];
    XCTAssertEqual(iter.blockThatReturnsHashKey, blockToReturnKey);

    XCTAssertEqualObjects([iter nextObject], d1);
    XCTAssertEqualObjects([iter nextObject], d2);
    XCTAssertEqualObjects([iter nextObject], d3);
    XCTAssertEqualObjects([iter nextObject], nil);
}

- (void)testPeak {
    NSDictionary *d1 = @{@"k": @1, @"v": @"foo1"};
    NSDictionary *d2 = @{@"k": @2, @"v": @"foo2"};
    NSDictionary *d3 = @{@"k": @3, @"v": @"foo3"};
    NSArray *data = @[d1, d2, d3];
    NSUInteger (^blockToReturnKey)(id object) = ^NSUInteger (id object) {
        NSDictionary *dictObject = object;
        return [[dictObject objectForKey:@"k"] unsignedIntValue];
    };

    MAVEMerkleTreeDataEnumerator *iter = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[data objectEnumerator] blockThatReturnsHashKey:blockToReturnKey];
    XCTAssertEqual(iter.blockThatReturnsHashKey, blockToReturnKey);

    XCTAssertEqualObjects([iter peekAtNextObject], d1);
    // can call multiple times
    XCTAssertEqualObjects([iter peekAtNextObject], d1);
    [iter nextObject];
    XCTAssertEqualObjects([iter peekAtNextObject], d2);
    [iter nextObject];
    XCTAssertEqualObjects([iter peekAtNextObject], d3);
    [iter nextObject];
    XCTAssertEqualObjects([iter peekAtNextObject], nil);
}

- (void)testKeyForNextObject {
    NSDictionary *d1 = @{@"k": @1, @"v": @"foo1"};
    NSArray *data = @[d1];
    NSUInteger (^blockToReturnKey)(id object) = ^NSUInteger (id object) {
        NSDictionary *dictObject = object;
        return [[dictObject objectForKey:@"k"] unsignedIntValue];
    };
    MAVEMerkleTreeDataEnumerator *iter = [[MAVEMerkleTreeDataEnumerator alloc] initWithEnumerator:[data objectEnumerator] blockThatReturnsHashKey:blockToReturnKey];

    XCTAssertEqual([iter keyForNextObject], 1);
    XCTAssertEqualObjects([iter nextObject], d1);
}

@end
