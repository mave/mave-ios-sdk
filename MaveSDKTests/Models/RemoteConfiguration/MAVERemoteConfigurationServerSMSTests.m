//
//  MAVERemoteConfigurationServerSMSTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/14/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationServerSMS.h"

@interface MAVERemoteConfigurationServerSMSTests : XCTestCase

@end

@implementation MAVERemoteConfigurationServerSMSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationServerSMS defaultJSONData];
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertNotNil(template);

    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");
    XCTAssertEqualObjects([template objectForKey:@"copy"],
                          @"Join me on DemoApp!");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationServerSMS *obj = [[MAVERemoteConfigurationServerSMS alloc] initWithDictionary:[MAVERemoteConfigurationServerSMS defaultJSONData]];

    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.text, @"Join me on DemoApp!");
}

- (void)testInitFailsIfTemplateMalformed {
    // missing the "text" parameter
    NSDictionary *data = @{@"template": @{@"template_id": @"foo"}};
    MAVERemoteConfigurationServerSMS *obj = [[MAVERemoteConfigurationServerSMS alloc] initWithDictionary:data];

    // "text" parameter is NSNull
    data = @{@"template": @{@"template_id": @"foo", @"copy": [NSNull null]}};
    obj = [[MAVERemoteConfigurationServerSMS alloc] initWithDictionary:data];

    XCTAssertNil(obj);
}

- (void)testNSNullVauesChangedToNil {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"template_id": [NSNull null],
                                   @"copy": @"foo",
                                   }
                           };
    MAVERemoteConfigurationServerSMS *obj = [[MAVERemoteConfigurationServerSMS alloc] initWithDictionary:dict];
    XCTAssertNotNil(obj); // text is required so this will still be nil
    // should be nil, not nsnull
    XCTAssertNil(obj.templateID);
}

@end
