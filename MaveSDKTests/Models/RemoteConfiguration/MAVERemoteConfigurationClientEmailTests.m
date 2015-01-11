//
//  MAVERemoteConfigurationClientEmailTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationClientEmail.h"

@interface MAVERemoteConfigurationClientEmailTests : XCTestCase

@end

@implementation MAVERemoteConfigurationClientEmailTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationClientEmail defaultJSONData];
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertNotNil(template);

    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");
    XCTAssertEqualObjects([template objectForKey:@"subject"], @"Join DemoApp");
    XCTAssertEqualObjects([template objectForKey:@"body"], @"Hey, I've been using DemoApp and thought you might like it. Check it out:\n\n");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationClientEmail *obj = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:[MAVERemoteConfigurationClientEmail defaultJSONData]];

    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.subject, @"Join DemoApp");
    XCTAssertEqualObjects(obj.body, @"Hey, I've been using DemoApp and thought you might like it. Check it out:\n\n");
}

- (void)testInitFailsIfTemplateMalformed {
    // missing the "body" parameter
    NSDictionary *data = @{@"template_id": @"foo", @"subject": @"blah"};
    MAVERemoteConfigurationClientEmail *obj = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:data];

    XCTAssertNil(obj);
}

@end
