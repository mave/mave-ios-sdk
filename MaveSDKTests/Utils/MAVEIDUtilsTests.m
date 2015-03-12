//
//  MAVEIDUtilsTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/21/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEIDUtils.h"

@interface MAVEIDUtilsTests : XCTestCase

@end

@implementation MAVEIDUtilsTests

- (void)setUp {
    [super setUp];
    [MAVEIDUtils clearStoredAppDeviceID];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGenerateUUIDString {
    NSString *uuid1 = [MAVEIDUtils generateAppDeviceIDUUIDString];
    
    XCTAssertNotNil(uuid1);
    // Looks roughly like a UUID, 8-4-4-4-12 chars
    XCTAssertEqual([uuid1 length], 36);
    XCTAssertEqualObjects([uuid1 substringWithRange:NSMakeRange(8, 1)], @"-");
    XCTAssertEqualObjects([uuid1 substringWithRange:NSMakeRange(13, 1)], @"-");
    XCTAssertEqualObjects([uuid1 substringWithRange:NSMakeRange(18, 1)], @"-");
    XCTAssertEqualObjects([uuid1 substringWithRange:NSMakeRange(23, 1)], @"-");

    // Each call returns a new one
    XCTAssertNotEqual(uuid1, [MAVEIDUtils generateAppDeviceIDUUIDString]);
}

- (void)testCreateAndLoadAppDeviceID {
    NSString *uuid = [MAVEIDUtils loadOrCreateNewAppDeviceID];
    XCTAssertNotNil(uuid);
    XCTAssertEqualObjects(uuid, [MAVEIDUtils loadOrCreateNewAppDeviceID]);
}

- (void) testClearStoredAppDeviceIDClearsItButThenItGetsReCreated {
    NSString *uuid1 = [MAVEIDUtils loadOrCreateNewAppDeviceID];
    [MAVEIDUtils clearStoredAppDeviceID];
    XCTAssertFalse([MAVEIDUtils isAppDeviceIDStoredToDefaults]);
    NSString *uuid2 = [MAVEIDUtils loadOrCreateNewAppDeviceID];
    XCTAssertTrue([MAVEIDUtils isAppDeviceIDStoredToDefaults]);
    XCTAssertNotNil(uuid2);
    XCTAssertNotEqualObjects(uuid1, uuid2);
}

- (void)testClearStoredAppDeviceIDWorksWhenAlreadyCleared {
    // Should not throw exception
    [MAVEIDUtils clearStoredAppDeviceID];
    [MAVEIDUtils clearStoredAppDeviceID];
}
@end
