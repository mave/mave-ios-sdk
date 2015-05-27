//
//  MAVECustomContactInfoRowV3Tests.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/27/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVECustomContactInfoRowV3.h"
#import "MAVEDisplayOptionsFactory.h"
#import <OCMock/OCMock.h>

@interface MAVECustomContactInfoRowV3Tests : XCTestCase

@end

@implementation MAVECustomContactInfoRowV3Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitialSetup {
    UIFont *font1 = [MAVEDisplayOptionsFactory randomFont];
    UIColor *color1 = [MAVEDisplayOptionsFactory randomColor];
    UIColor *color2 = [MAVEDisplayOptionsFactory randomColor];
    MAVECustomContactInfoRowV3 *row = [[MAVECustomContactInfoRowV3 alloc] initWithFont:font1 selectedColor:color1 deselectedColor:color2];
    XCTAssertNotNil(row);
    XCTAssertNotNil(row.label);
    XCTAssertNotNil(row.checkmarkView);
    XCTAssertNotNil(row.checkmarkView.image);
    XCTAssertTrue([row.label isDescendantOfView:row]);
    XCTAssertTrue([row.checkmarkView isDescendantOfView:row]);
}

- (void)testHeightGivenFont {
    UIFont *font = [UIFont systemFontOfSize:14];
    // hardcode the value we expect so test will notify us if it changes
    XCTAssertLessThan(ABS([MAVECustomContactInfoRowV3 heightGivenFont:font] - 24.7f), 0.1);
}

- (void)testSetIsSelected {
    UIFont *font1 = [MAVEDisplayOptionsFactory randomFont];
    UIColor *color1 = [MAVEDisplayOptionsFactory randomColor];
    UIColor *color2 = [MAVEDisplayOptionsFactory randomColor];
    MAVECustomContactInfoRowV3 *row = [[MAVECustomContactInfoRowV3 alloc] initWithFont:font1 selectedColor:color1 deselectedColor:color2];
    XCTAssertFalse(row.isSelected);
    XCTAssertTrue(row.checkmarkView.hidden);
    XCTAssertEqualObjects(row.label.textColor, color2);

    row.isSelected = YES;
    XCTAssertTrue(row.isSelected);
    XCTAssertFalse(row.checkmarkView.hidden);
    XCTAssertEqualObjects(row.label.textColor, color1);

    row.isSelected = NO;
    XCTAssertFalse(row.isSelected);
    XCTAssertTrue(row.checkmarkView.hidden);
    XCTAssertEqualObjects(row.label.textColor, color2);
}

- (void)testUpdateWithLabelTextAndSelectedStatus {
    UIFont *font1 = [MAVEDisplayOptionsFactory randomFont];
    UIColor *color1 = [MAVEDisplayOptionsFactory randomColor];
    UIColor *color2 = [MAVEDisplayOptionsFactory randomColor];
    MAVECustomContactInfoRowV3 *row = [[MAVECustomContactInfoRowV3 alloc] initWithFont:font1 selectedColor:color1 deselectedColor:color2];
    id rowMock = OCMPartialMock(row);
    OCMExpect([rowMock setIsSelected:YES]);

    [row updateWithLabelText:@"foobarbaz" isSelected:YES];
    XCTAssertEqualObjects(row.label.text, @"foobarbaz");
    OCMVerifyAll(rowMock);
}

@end
