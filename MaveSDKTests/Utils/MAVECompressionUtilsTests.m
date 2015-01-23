//
//  MAVECompressionUtilsTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVECompressionUtils.h"

@interface MAVECompressionUtilsTests : XCTestCase

@end

@implementation MAVECompressionUtilsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGZipCompressAndUncompress {
    NSString *initialValue = @"foobar hello danny ☃";
    NSData *initialData = [initialValue dataUsingEncoding:NSUTF8StringEncoding];

    NSData *compressedData = [MAVECompressionUtils gzipCompressData:initialData];
    XCTAssertNotNil(compressedData);
    NSData *uncompressedData = [MAVECompressionUtils gzipUncompressData:compressedData];
    NSString *uncompressedValue = [[NSString alloc] initWithData:uncompressedData encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(uncompressedData, initialData);
    XCTAssertEqualObjects(uncompressedValue, initialValue);
}

@end
