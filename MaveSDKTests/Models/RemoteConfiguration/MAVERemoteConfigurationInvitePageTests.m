//
//  MAVERemoteConfigurationInvitePageTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/10/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationContactsInvitePage.h"

@interface MAVERemoteConfigurationInvitePageTests : XCTestCase

@end

@implementation MAVERemoteConfigurationInvitePageTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultJSON {
    NSDictionary *defaults = [MAVERemoteConfigurationContactsInvitePage defaultJSONData];

    XCTAssertTrue([[defaults objectForKey:@"enabled"] boolValue]);
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");

    XCTAssertNil([template objectForKey:@"explanation_copy"]);
    // The actual app name here comes from the bundle name, this test always runs in
    // the context of the demo app
    XCTAssertEqualObjects([template objectForKey:@"sms_copy"],
                          @"Join me on DemoApp!");
}

- (void)testInitWithDefaultData {
    MAVERemoteConfigurationContactsInvitePage *obj = [[MAVERemoteConfigurationContactsInvitePage alloc]
        initWithDictionary:[
            MAVERemoteConfigurationContactsInvitePage defaultJSONData]];
    XCTAssertTrue(obj.enabled);
    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertNil(obj.explanationCopy);
    XCTAssertEqualObjects(obj.smsCopy, @"Join me on DemoApp!");
}

- (void)testInitFailsIfEnabledKeyIsMissing {
    // init the normal values dict but leave "enabled" empty
    NSDictionary *defaultDict = [MAVERemoteConfigurationContactsInvitePage defaultJSONData];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[defaultDict objectForKey:@"template"] forKey:@"template"];

    MAVERemoteConfigurationContactsInvitePage *obj = [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:dict];

    XCTAssertNil(obj);
}

- (void)testInitFailsIfEnabledTrueAndTemplateMissingFields {
    NSDictionary *dict = @{
        @"enabled": @YES,
        @"template": @{
            @"template_id": @"foo",
            @"explanation_copy": @"blah"
        }
    };

    MAVERemoteConfigurationContactsInvitePage *obj = [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:dict];

    XCTAssertNil(obj);
}

- (void)testInitSuccessIfNoTemplateButEnabledFalse {
    NSDictionary *dict = @{@"enabled": @NO, @"template": [NSNull null]};
    MAVERemoteConfigurationContactsInvitePage *obj = [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:dict];

    XCTAssertNotNil(obj);
    XCTAssertFalse(obj.enabled);
    XCTAssertNil(obj.templateID);
}

@end
