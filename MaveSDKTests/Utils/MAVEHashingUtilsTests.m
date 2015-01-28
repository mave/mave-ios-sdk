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

- (void)testHexStringValue {
    // try nil, 0 and other data values4
    NSData *d1 = nil;
    uint d2i = 0;  NSData *d2 = [NSData dataWithBytes:&d2i length:0];
    uint d3i = 0; NSData *d3 = [NSData dataWithBytes:&d3i length:1];
    uint d4i = 1; NSData *d4 = [NSData dataWithBytes:&d4i length:4];
    uint d5i = 0xd41d8cd9; NSData *d5 = [NSData dataWithBytes:&d5i length:4];
    int d6i = 0xffffffff; NSData *d6 = [NSData dataWithBytes:&d6i length:4];
    u_long d7i = ULLONG_MAX; NSData *d7 = [NSData dataWithBytes:&d7i length:8];

    // Test zero values
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:d1], nil);
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:d2], @"");
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:d3], @"00");
    // ARM is little endian, so reverse bytes for in between values
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:d4], @"01000000");
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:d5], @"d98c1dd4");
    // Test maximums
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:d6], @"ffffffff");
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:d7], @"ffffffffffffffff");
}

- (void)testDataFromHexString {
    uint d1i = CFSwapInt32BigToHost(0x0088ff00); NSData *d1 = [NSData dataWithBytes:&d1i length:3];
    NSString *hexString = @"0088ff";
    NSData *outputData = [MAVEHashingUtils dataFromHexString:hexString];
    XCTAssertEqual([outputData length], 3);
    XCTAssertEqualObjects(outputData, d1);

    // convert back to string
    NSString *outputString = [MAVEHashingUtils hexStringFromData:outputData];
    XCTAssertEqualObjects(outputString, hexString);
}

- (void)testHexStringToDataAndBack {
    // Try another string
    NSString *hexString2 = @"0003";
    NSData *dataVersion = [MAVEHashingUtils dataFromHexString:hexString2];
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:dataVersion], hexString2);
}

- (void)testDataFromEmptyHexString {
    NSData *empty = [[NSData alloc] init];
    XCTAssertEqualObjects([MAVEHashingUtils dataFromHexString:@""], empty);
    XCTAssertNil([MAVEHashingUtils dataFromHexString:nil]);
}

- (void)testHashStringValue {
    // try an empty string, short string, long string
    NSString *s1 = @"";
    NSString *s2 = @"foo";
    NSString *s3 = @"Hello, this is quite a long string here it is certainly longer than the 128 bit md5 output";
    NSData *md51 = [MAVEHashingUtils md5Hash:[s1 dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *md52 = [MAVEHashingUtils md5Hash:[s2 dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *md53 = [MAVEHashingUtils md5Hash:[s3 dataUsingEncoding:NSUTF8StringEncoding]];

    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:md51], @"d41d8cd98f00b204e9800998ecf8427e");
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:md52], @"acbd18db4cc2f85cedef654fccc4a4d8");
    XCTAssertEqualObjects([MAVEHashingUtils hexStringFromData:md53], @"7016fb20cebc07b93c8a289da7a0deaa");
}

- (void)testRandomizeInt32 {
    int32_t int1 = 1;
    NSUInteger hash1 = 0xf1450306517624a5;
    int32_t int2 = -1;
    NSUInteger hash2 = 0xa54f0041a9e15b05;
    int32_t int3 = 2147483647;  // 2^31 - 1, max signed int
    NSUInteger hash3 = 0x37497ad6a0c4f123;

    XCTAssertEqual([MAVEHashingUtils randomizeInt32WithMD5hash:int1], hash1);
    XCTAssertEqual([MAVEHashingUtils randomizeInt32WithMD5hash:int2], hash2);
    XCTAssertEqual([MAVEHashingUtils randomizeInt32WithMD5hash:int3], hash3);
}

@end
