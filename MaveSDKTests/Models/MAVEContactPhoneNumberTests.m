//
//  MAVEContactPhoneNumberTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/27/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEContactPhoneNumber.h"
#import "MAVEContactEmail.h"

@interface MAVEContactPhoneNumberTests : XCTestCase

@end

@implementation MAVEContactPhoneNumberTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitAndSanityCheck {
    MAVEContactPhoneNumber *phone = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:@"_$!<Main>!$_"];
    XCTAssertEqualObjects(phone.value, @"+18085551234");
    XCTAssertEqualObjects(phone.label, @"_$!<Main>!$_");
    XCTAssertEqualObjects(phone.typeName, @"phone");
    XCTAssertEqualObjects([phone humanReadableValue], @"(808)\u00a0555-1234");
    XCTAssertEqualObjects([phone humanReadableLabel], @"main");
    XCTAssertEqualObjects([phone humanReadableValueWithLabel], @"(808)\u00a0555-1234 (main)");
}

- (void)testInitWithAllLabelTypes {
    MAVEContactPhoneNumber *phone;
    XCTAssertEqualObjects(MAVEContactPhoneLabelMain, @"_$!<Main>!$_");
    XCTAssertEqualObjects(MAVEContactPhoneHumanReadableLabelMain, @"main");
    phone = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMain];
    XCTAssertEqualObjects(phone.label, MAVEContactPhoneLabelMain);
    XCTAssertEqualObjects(phone.humanReadableLabel, MAVEContactPhoneHumanReadableLabelMain);

    XCTAssertEqualObjects(MAVEContactPhoneLabelMobile, @"_$!<Mobile>!$_");
    XCTAssertEqualObjects(MAVEContactPhoneHumanReadableLabelMobile, @"cell");
    phone = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    XCTAssertEqualObjects(phone.label, MAVEContactPhoneLabelMobile);
    XCTAssertEqualObjects(phone.humanReadableLabel, MAVEContactPhoneHumanReadableLabelMobile);

    XCTAssertEqualObjects(MAVEContactPhoneLabelOther, @"_$!<Other>!$_");
    XCTAssertEqualObjects(MAVEContactPhoneHumanReadableLabelOther, @"other");
    phone = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelOther];
    XCTAssertEqualObjects(phone.label, MAVEContactPhoneLabelOther);
    XCTAssertEqualObjects(phone.humanReadableLabel, MAVEContactPhoneHumanReadableLabelOther);
}

- (void)testInitConvertsUnknownLabelToOther {
    MAVEContactPhoneNumber *phone = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:@"foobar"];
    XCTAssertEqualObjects(phone.label, MAVEContactPhoneLabelOther);
    XCTAssertEqualObjects(phone.humanReadableLabel, MAVEContactPhoneHumanReadableLabelOther);
}

@end
