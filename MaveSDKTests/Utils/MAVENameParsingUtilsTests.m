//
//  MAVENameParsingUtilsTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/12/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVENameParsingUtils.h"

@interface MAVENameParsingUtilsTests : XCTestCase

@end

@implementation MAVENameParsingUtilsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testJoinFirstAndLastName {
    NSString *full;
    full = [MAVENameParsingUtils joinFirstName:@"Foo" andLastName:@"Bar"];
    XCTAssertEqualObjects(full, @"Foo Bar");

    full = [MAVENameParsingUtils joinFirstName:@"Foo" andLastName:nil];
    XCTAssertEqualObjects(full, @"Foo");

    full = [MAVENameParsingUtils joinFirstName:@"Foo" andLastName:@""];
    XCTAssertEqualObjects(full, @"Foo");

    full = [MAVENameParsingUtils joinFirstName:nil andLastName:@"Bar"];
    XCTAssertEqualObjects(full, @"Bar");

    full = [MAVENameParsingUtils joinFirstName:nil andLastName:nil];
    XCTAssertEqualObjects(full, nil);
}

// Tests for the name parsing utility, variations of "name <device type>"
- (void)testParseNameDeviceTypeStyleNames {
    NSString *firstName, *lastName;

    // Try with a standard device name
    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"Danny's iPhone"];
    XCTAssertEqualObjects(firstName, @"Danny");
    XCTAssertNil(lastName);

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"Danny's iPhone 5s"];
    XCTAssertEqualObjects(firstName, @"Danny");
    XCTAssertNil(lastName);

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"danny iPhone 5s"];
    XCTAssertEqualObjects(firstName, @"danny");
    XCTAssertNil(lastName);

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"dannyiphone5sblah"];
    XCTAssertEqualObjects(firstName, @"danny");
    XCTAssertNil(lastName);

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"dannyipad"];
    XCTAssertEqualObjects(firstName, @"danny");
    XCTAssertNil(lastName);

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"danny-ipad"];
    XCTAssertEqualObjects(firstName, @"danny");
    XCTAssertNil(lastName);

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"Danny Cosson's iPhone 5s"];
    XCTAssertEqualObjects(firstName, @"Danny");
    XCTAssertEqualObjects(lastName, @"Cosson");

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"danny-cosson-ipad-air-2"];
    XCTAssertEqualObjects(firstName, @"danny");
    XCTAssertEqualObjects(lastName, @"cosson");

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"kortina5iphone"];
    XCTAssertEqualObjects(firstName, @"kortina");
    XCTAssertNil(lastName);
}

// Test initializing for device name's that don't contain the person's name
- (void)testInitAutomaticallyFromDeviceNameNotEnoughInfo {
    NSString *firstName, *lastName;

    // Try with a standard device name
    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"iPhone Simulator"];
    XCTAssertNil(lastName);
    XCTAssertNil(lastName);

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"iPad Mini"];
    XCTAssertNil(firstName);
    XCTAssertNil(lastName);
}

- (void)testDontUseBadWords {
    NSString *firstName, *lastName;

    // Try with a standard device name
    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"Fuck This iPhone"];
    XCTAssertNil(lastName);
    XCTAssertNil(lastName);

    firstName = nil; lastName = nil;
    [MAVENameParsingUtils fillFirstName:&firstName lastName:&lastName
                         fromDeviceName:@"Balls iPad"];
    XCTAssertNil(firstName);
    XCTAssertNil(lastName);
}

#pragma mark - Bad Words list

- (void)testIsBadWord {
    XCTAssertTrue([MAVENameParsingUtils isBadWord:@"fuck"]);
    XCTAssertTrue([MAVENameParsingUtils isBadWord:@"fUCk"]);
    XCTAssertTrue([MAVENameParsingUtils isBadWord:@"FUCK"]);
    XCTAssertTrue([MAVENameParsingUtils isBadWord:@"4R5e"]);

    XCTAssertFalse([MAVENameParsingUtils isBadWord:nil]);
    XCTAssertFalse([MAVENameParsingUtils isBadWord:@"Flock"]);
    XCTAssertFalse([MAVENameParsingUtils isBadWord:@"Danny"]);
}

- (void)testBadWordsList {
    XCTAssertLessThan([[MAVENameParsingUtils badWordsList] count], 1000);
    XCTAssertGreaterThan([[MAVENameParsingUtils badWordsList] count], 200);
}


@end
