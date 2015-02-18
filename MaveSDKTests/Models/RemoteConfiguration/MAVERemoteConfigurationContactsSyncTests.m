//
//  MAVERemoteConfigurationContactsSyncTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/18/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationContactsSync.h"

@interface MAVERemoteConfigurationContactsSyncTests : XCTestCase

@end

@implementation MAVERemoteConfigurationContactsSyncTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationContactsSync defaultJSONData];
    XCTAssertFalse([[defaults objectForKey:@"enabled"] boolValue]);
}

- (void)testInitFromDefaultData {
    NSDictionary *data = [MAVERemoteConfigurationContactsSync defaultJSONData];
    MAVERemoteConfigurationContactsSync *config = [[MAVERemoteConfigurationContactsSync alloc] initWithDictionary:data];
    XCTAssertFalse(config.enabled);
}

- (void)testInitFromOtherDictValues {
    NSDictionary *data = @{@"enabled": @YES};
    MAVERemoteConfigurationContactsSync *config = [[MAVERemoteConfigurationContactsSync alloc] initWithDictionary:data];
    XCTAssertTrue(config.enabled);

    NSDictionary *data2 = @{@"enabled": @NO};
    MAVERemoteConfigurationContactsSync *config2 = [[MAVERemoteConfigurationContactsSync alloc] initWithDictionary:data2];
    XCTAssertFalse(config2.enabled);

    NSDictionary *data3 = @{@"enabled": [NSNull null]};
    MAVERemoteConfigurationContactsSync *config3 = [[MAVERemoteConfigurationContactsSync alloc] initWithDictionary:data3];
    XCTAssertFalse(config3.enabled);

    NSDictionary *data4 = @{@"enabled": @"string"};
    MAVERemoteConfigurationContactsSync *config4 = [[MAVERemoteConfigurationContactsSync alloc] initWithDictionary:data4];
    XCTAssertFalse(config4.enabled);

    NSDictionary *data5 = @{};
    MAVERemoteConfigurationContactsSync *config5 = [[MAVERemoteConfigurationContactsSync alloc] initWithDictionary:data5];
    XCTAssertFalse(config5.enabled);
}

@end
