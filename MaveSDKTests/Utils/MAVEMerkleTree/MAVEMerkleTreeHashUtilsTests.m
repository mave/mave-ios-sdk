//
//  MAVEMerkleTreeHashUtilsTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEMerkleTreeHashUtils.h"

@interface MAVEMerkleTreeHashUtilsTests : XCTestCase

@end

@implementation MAVEMerkleTreeHashUtilsTests

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
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:d1], nil);
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:d2], @"");
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:d3], @"00");
    // ARM is little endian, so reverse bytes for in between values
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:d4], @"01000000");
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:d5], @"d98c1dd4");
    // Test maximums
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:d6], @"ffffffff");
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:d7], @"ffffffffffffffff");
}

- (void)testDataFromHexString {
    uint d1i = CFSwapInt32BigToHost(0x0088ff00); NSData *d1 = [NSData dataWithBytes:&d1i length:3];
    NSString *hexString = @"0088ff";
    NSData *outputData = [MAVEMerkleTreeHashUtils dataFromHexString:hexString];
    XCTAssertEqual([outputData length], 3);
    XCTAssertEqualObjects(outputData, d1);

    // convert back to string
    NSString *outputString = [MAVEMerkleTreeHashUtils hexStringFromData:outputData];
    XCTAssertEqualObjects(outputString, hexString);
}

- (void)testHexStringToDataAndBack {
    // Try another string
    NSString *hexString2 = @"0003";
    NSData *dataVersion = [MAVEMerkleTreeHashUtils dataFromHexString:hexString2];
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:dataVersion], hexString2);
}

- (void)testDataFromEmptyHexString {
    NSData *empty = [[NSData alloc] init];
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils dataFromHexString:@""], empty);
    XCTAssertNil([MAVEMerkleTreeHashUtils dataFromHexString:nil]);
}

- (void)testUint64FromData {
    // data value 1
    NSData *data0 = [MAVEMerkleTreeHashUtils dataFromHexString:@"0000000000000001"];
    XCTAssertEqual([MAVEMerkleTreeHashUtils UInt64FromData:data0], 1);

    // data of max value
    NSData *data1 = [MAVEMerkleTreeHashUtils dataFromHexString:@"ffffffffffffffff"];
    XCTAssertEqual([MAVEMerkleTreeHashUtils UInt64FromData:data1], UINT64_MAX);

    // data zero value
    NSData *data2 = [MAVEMerkleTreeHashUtils dataFromHexString:@"0000000000000000"];
    XCTAssertEqual([MAVEMerkleTreeHashUtils UInt64FromData:data2], 0);
}

- (void)testUint64FromDataWhenGreaterThan8Bytes {
    // 9 bytes of data, which will just use the first 8
    NSData *data1 = [@"abcdefghi" dataUsingEncoding:NSASCIIStringEncoding];
    NSData *data2 = [@"abcdefgh" dataUsingEncoding:NSASCIIStringEncoding];
    XCTAssertEqual([MAVEMerkleTreeHashUtils UInt64FromData:data1],
                   [MAVEMerkleTreeHashUtils UInt64FromData:data2]);
}

- (void)testUint64FromDataWhenLessThan8Bytes {
    // Should pad the left side with zeros when data is less than 8 bytes
    NSData *data1 = [MAVEMerkleTreeHashUtils dataFromHexString:@"01"];
    XCTAssertEqual([MAVEMerkleTreeHashUtils UInt64FromData:data1], 1);
}

- (void)testDataFromInt32 {
    NSString *output0 = [MAVEMerkleTreeHashUtils hexStringFromData:
                         [MAVEMerkleTreeHashUtils dataFromInt32:1]];
    XCTAssertEqualObjects(output0, @"00000001");
    NSString *output1 = [MAVEMerkleTreeHashUtils hexStringFromData:
                         [MAVEMerkleTreeHashUtils dataFromInt32:0]];
    XCTAssertEqualObjects(output1, @"00000000");
    NSString *output2 = [MAVEMerkleTreeHashUtils hexStringFromData:
                         [MAVEMerkleTreeHashUtils dataFromInt32:-1]];
    XCTAssertEqualObjects(output2, @"ffffffff");
    NSString *output3 = [MAVEMerkleTreeHashUtils hexStringFromData:
                         [MAVEMerkleTreeHashUtils dataFromInt32:INT32_MAX]];
    XCTAssertEqualObjects(output3, @"7fffffff");
}

- (void)testMd5Hash {
    // try an empty string, short string, long string
    NSString *s1 = @"";
    NSString *s2 = @"foo";
    NSString *s3 = @"Hello, this is quite a long string here it is certainly longer than the 128 bit md5 output";
    NSData *md51 = [MAVEMerkleTreeHashUtils md5Hash:[s1 dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *md52 = [MAVEMerkleTreeHashUtils md5Hash:[s2 dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *md53 = [MAVEMerkleTreeHashUtils md5Hash:[s3 dataUsingEncoding:NSUTF8StringEncoding]];

    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:md51], @"d41d8cd98f00b204e9800998ecf8427e");
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:md52], @"acbd18db4cc2f85cedef654fccc4a4d8");
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:md53], @"7016fb20cebc07b93c8a289da7a0deaa");
}

- (void)testMd5HashTruncated {
    NSString *s2 = @"foo";
    NSData *md52 = [MAVEMerkleTreeHashUtils md5Hash:[s2 dataUsingEncoding:NSUTF8StringEncoding] truncatedToBytes:2];
    XCTAssertEqualObjects([MAVEMerkleTreeHashUtils hexStringFromData:md52], @"acbd");
}


@end
