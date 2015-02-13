//
//  MAVERange64Tests.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/13/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERange64.h"

@interface MAVERange64Tests : XCTestCase

@end

@implementation MAVERange64Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMakeRange64 {
    MAVERange64 *range1 = MAVEMakeRange64(0, 0);
    XCTAssertEqual(range1.location, 0);
    XCTAssertEqual(range1.length, 0);

    MAVERange64 *range2 = MAVEMakeRange64(0, 1);
    XCTAssertEqual(range2.location, 0);
    XCTAssertEqual(range2.length, 1);

    MAVERange64 *range3 = MAVEMakeRange64(0, UINT64_MAX);
    uint64_t expectedMax = 1844674407370955161 * 10 + 5;
    XCTAssertEqual(range3.location, 0);
    XCTAssertEqual(range3.length, expectedMax);
}

- (void)testLocationInRange {
    MAVERange64 *range1 = MAVEMakeRange64(0, 0);
    XCTAssertFalse(MAVELocationInRange64(0, range1));

    MAVERange64 *range2 = MAVEMakeRange64(1, 2);
    XCTAssertFalse(MAVELocationInRange64(0, range2));
    XCTAssertTrue(MAVELocationInRange64(1, range2));
    XCTAssertTrue(MAVELocationInRange64(2, range2));
    XCTAssertFalse(MAVELocationInRange64(3, range2));

    MAVERange64 *range3 = MAVEMakeRange64(0, UINT64_MAX);
    XCTAssertTrue(MAVELocationInRange64(0, range3));
    XCTAssertTrue(MAVELocationInRange64(UINT64_MAX - 1, range3));
}

@end
