//
//  MAVEMerkleTreeUtilsTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/28/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEMerkleTreeUtils.h"

@interface MAVEMerkleTreeUtilsTests : XCTestCase

@end

@implementation MAVEMerkleTreeUtilsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testJSONSerialize {
    NSArray *obj = @[@"foo", @1];
    NSData *data = [MAVEMerkleTreeUtils JSONSerialize:obj];

    NSData *expected = [@"[\"foo\",1]" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(data, expected);
}

@end
