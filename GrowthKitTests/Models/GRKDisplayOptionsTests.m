//
//  GRKDisplayOptionsTests.m
//  GrowthKit
//
//  Created by dannycosson on 10/20/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "GRKDisplayOptions.h"
#import "GRKDisplayOptionsFactory.h"

@interface GRKDisplayOptionsTests : XCTestCase

@end

@implementation GRKDisplayOptionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultOptions {
    GRKDisplayOptions *opts = [[GRKDisplayOptions alloc] initWithDefaults];

    UIFont *defaultFont = [UIFont systemFontOfSize:16];
    UIColor *white = [[UIColor alloc] initWithWhite:0 alpha:1];
    UIColor *almostBlack = [[UIColor alloc] initWithWhite:0.15 alpha:1.0];
    UIColor *lightGrey = [[UIColor alloc] initWithWhite:0.65 alpha:1.0];
    UIColor *blueTint = [[UIColor alloc] initWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    XCTAssertEqualObjects(opts.primaryFont, defaultFont);
    XCTAssertEqualObjects(opts.primaryTextColor, almostBlack);
    XCTAssertEqualObjects(opts.secondaryTextColor, lightGrey);
    XCTAssertEqualObjects(opts.tintColor, blueTint);

    XCTAssertEqualObjects(opts.navigationBarBackgroundColor, white);
    XCTAssertEqualObjects(opts.bottomViewBackgroundColor, white);
    XCTAssertEqualObjects(opts.tableCellBackgroundColor, white);
    XCTAssertEqualObjects(opts.tableSectionBackgroundColor, lightGrey);
}

- (void)testFactoryFillsOptions {
    GRKDisplayOptions *opts = [GRKDisplayOptionsFactory generateDisplayOptions];

    XCTAssertTrue([opts.primaryFont isKindOfClass: [UIFont class]]);
    XCTAssertTrue([opts.primaryTextColor isKindOfClass: [UIColor class]]);
    XCTAssertTrue([opts.secondaryTextColor isKindOfClass: [UIColor class]]);
    XCTAssertTrue([opts.tintColor isKindOfClass: [UIColor class]]);

    XCTAssertTrue([opts.navigationBarBackgroundColor isKindOfClass: [UIColor class]]);
    XCTAssertTrue([opts.bottomViewBackgroundColor isKindOfClass: [UIColor class]]);
    XCTAssertTrue([opts.tableCellBackgroundColor isKindOfClass: [UIColor class]]);
    XCTAssertTrue([opts.tableSectionBackgroundColor isKindOfClass: [UIColor class]]);
}

@end