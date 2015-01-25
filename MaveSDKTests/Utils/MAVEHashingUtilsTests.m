//
//  MAVEHashingUtilsTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEHashingUtils.h"

@interface MAVEHashingUtilsTests : XCTestCase

@end

@implementation MAVEHashingUtilsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHashStringValue {
    // try an empty string, short string, long string
    NSString *s1 = @"";
    NSString *s2 = @"foo";
    NSString *s3 = @"Hello, this is quite a long string here it is certainly longer than the 128 bit md5 output";
    NSString *md51 = [MAVEHashingUtils md5HashHexStringValue:[s1 dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *md52 = [MAVEHashingUtils md5HashHexStringValue:[s2 dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *md53 = [MAVEHashingUtils md5HashHexStringValue:[s3 dataUsingEncoding:NSUTF8StringEncoding]];

    XCTAssertEqualObjects(md51, @"d41d8cd98f00b204e9800998ecf8427e");
    XCTAssertEqualObjects(md52, @"acbd18db4cc2f85cedef654fccc4a4d8");
    XCTAssertEqualObjects(md53, @"7016fb20cebc07b93c8a289da7a0deaa");
}

@end
