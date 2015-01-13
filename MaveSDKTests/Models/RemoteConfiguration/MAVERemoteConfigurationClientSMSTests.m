//
//  MAVERemoteConfigurationClientSMSTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationClientSMS.h"

@interface MAVERemoteConfigurationClientSMSTests : XCTestCase

@end

@implementation MAVERemoteConfigurationClientSMSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationClientSMS defaultJSONData];
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertNotNil(template);

    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");
    XCTAssertEqualObjects([template objectForKey:@"copy"],
                          @"Join me on DemoApp!");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationClientSMS *obj = [[MAVERemoteConfigurationClientSMS alloc] initWithDictionary:[MAVERemoteConfigurationClientSMS defaultJSONData]];

    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.text, @"Join me on DemoApp!");
}

- (void)testInitFailsIfTemplateMalformed {
    // missing the "text" parameter
    NSDictionary *data = @{@"template": @{@"template_id": @"foo"}};
    MAVERemoteConfigurationClientSMS *obj = [[MAVERemoteConfigurationClientSMS alloc] initWithDictionary:data];

    XCTAssertNil(obj);
}

@end
