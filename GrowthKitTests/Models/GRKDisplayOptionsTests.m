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

    UIFont *defaultFont = [UIFont systemFontOfSize:14];
    UIFont *smallerFont = [UIFont systemFontOfSize:12];
    UIFont *smallerBoldFont = [UIFont boldSystemFontOfSize:12];
    UIColor *white = [[UIColor alloc] initWithWhite:1.0 alpha:1];
    UIColor *almostBlack = [[UIColor alloc] initWithWhite:0.15 alpha:1.0];
    UIColor *mediumGrey = [[UIColor alloc] initWithWhite:0.65 alpha:1.0];
    UIColor *lightGrey = [[UIColor alloc] initWithWhite:0.70 alpha:1.0];
    UIColor *extraLightGrey = [[UIColor alloc] initWithWhite:0.95 alpha:1.0];
    UIColor *blueTint = [[UIColor alloc] initWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];

    // Header options
    XCTAssertEqualObjects(opts.navigationBarBackgroundColor, white);
    XCTAssertEqualObjects(opts.navigationBarTitleColor, almostBlack);
    XCTAssertEqualObjects(opts.navigationBarTitleFont, defaultFont);
    XCTAssertEqualObjects(opts.navigationBarCancelButton.title, @"Cancel");

    // "Friends to invite" table options
    XCTAssertEqualObjects(opts.personNameFont, defaultFont);
    XCTAssertEqualObjects(opts.personContactInfoFont, smallerFont);
    XCTAssertEqualObjects(opts.sectionHeaderFont, smallerBoldFont);
    XCTAssertEqualObjects(opts.sectionIndexColor, lightGrey);
    XCTAssertEqualObjects(opts.checkmarkColor, blueTint);
    
    // Message and Send section options
    XCTAssertEqualObjects(opts.bottomViewBackgroundColor, white);
    XCTAssertEqualObjects(opts.bottomViewBorderColor, mediumGrey);
    XCTAssertEqualObjects(opts.sendButtonFont, defaultFont);
    XCTAssertEqualObjects(opts.sendButtonColor, blueTint);
}

- (void)testFactoryFillsOptions {
    GRKDisplayOptions *opts = [GRKDisplayOptionsFactory generateDisplayOptions];

    // Header options
    XCTAssertTrue([opts.navigationBarBackgroundColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.navigationBarTitleColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.navigationBarTitleFont isKindOfClass:[UIFont class]]);
    XCTAssertEqualObjects(opts.navigationBarCancelButton.title, @"Cancel");
    
    // "Friends to invite" table options
    XCTAssertTrue([opts.personNameFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.personContactInfoFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.sectionHeaderFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.sectionIndexColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.checkmarkColor isKindOfClass:[UIColor class]]);
    
    // Message and Send section options
    XCTAssertTrue([opts.bottomViewBackgroundColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.bottomViewBorderColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.sendButtonFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.sendButtonColor isKindOfClass:[UIColor class]]);
}

@end