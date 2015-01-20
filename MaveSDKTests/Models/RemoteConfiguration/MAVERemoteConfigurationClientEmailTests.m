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
    // missing the subject & body parameter
    NSDictionary *data = @{@"template": @{@"template_id": @"foo"}};
    MAVERemoteConfigurationClientEmail *obj = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:data];

    data = @{@"template": @{@"template_id": @"foo", @"subject": [NSNull null], @"body": [NSNull null]}};
    obj = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:data];

    XCTAssertNil(obj);
}

- (void)testNSNullVauesChangedToNil {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"template_id": [NSNull null],
                                   @"subject": @"a",
                                   @"body": @"b",
                                   }
                           };
    MAVERemoteConfigurationClientEmail *obj = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:dict];
    // should be nil, not nsnull
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.templateID);
}

@end
