//
//  MAVERemoteConfigurationCustomSharePageTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/13/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationCustomSharePage.h"

@interface MAVERemoteConfigurationCustomSharePageTests : XCTestCase

@end

@implementation MAVERemoteConfigurationCustomSharePageTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultJSON {
    NSDictionary *defaults = [MAVERemoteConfigurationCustomSharePage defaultJSONData];

    XCTAssertTrue([[defaults objectForKey:@"enabled"] boolValue]);
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");

    // The actual app name here comes from the bundle name, this test always runs in
    // the context of the demo app
    XCTAssertEqualObjects([template objectForKey:@"explanation_copy"],
                          @"Share DemoApp with friends");
}

- (void)testInitWithDefaultData {
    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:[MAVERemoteConfigurationCustomSharePage defaultJSONData]];
    XCTAssertTrue(obj.enabled);
    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.explanationCopy,
                          @"Share DemoApp with friends");
}

- (void)testInitFailsIfEnabledKeyIsMissing {
    // init the normal values dict but leave "enabled" empty
    NSDictionary *defaultDict = [MAVERemoteConfigurationCustomSharePage defaultJSONData];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[defaultDict objectForKey:@"template"] forKey:@"template"];

    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:dict];

    XCTAssertNil(obj);
}

- (void)testInitFailsIfEnabledTrueAndTemplateMissingFields {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"template_id": @"foo",
                                   }
                           };

    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:dict];

    XCTAssertNil(obj);
}

- (void)testInitSucceedsIfTemplateIDEmpty {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"explanation_copy": @"",
                                   }
                           };

    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:dict];

    XCTAssertNotNil(obj);
    XCTAssertEqualObjects(obj.explanationCopy, @"");
}

- (void)testInitSuccessIfNoTemplateButEnabledFalse {
    NSDictionary *dict = @{@"enabled": @NO, @"template": [NSNull null]};
    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:dict];
    
    XCTAssertNotNil(obj);
    XCTAssertFalse(obj.enabled);
    XCTAssertNil(obj.templateID);
}

@end
