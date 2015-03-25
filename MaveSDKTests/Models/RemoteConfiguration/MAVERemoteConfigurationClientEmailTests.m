//
//  MAVERemoteConfigurationClientEmailTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVERemoteConfigurationClientEmail.h"
#import "MAVETemplatingUtils.h"

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
    XCTAssertEqualObjects([template objectForKey:@"subject_template"], @"Join DemoApp");
    XCTAssertEqualObjects([template objectForKey:@"body_template"], @"Hey, I've been using DemoApp and thought you might like it. Check it out:\n\n");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationClientEmail *obj = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:[MAVERemoteConfigurationClientEmail defaultJSONData]];

    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.subjectTemplate, @"Join DemoApp");
    XCTAssertEqualObjects(obj.bodyTemplate, @"Hey, I've been using DemoApp and thought you might like it. Check it out:\n\n");
}

- (void)testInitFailsIfTemplateMalformed {
    // missing the subject & body parameter
    NSDictionary *data = @{@"template": @{@"template_id": @"foo"}};
    MAVERemoteConfigurationClientEmail *obj = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:data];

    data = @{@"template": @{@"template_id": @"foo", @"subject_template": [NSNull null], @"body_template": [NSNull null]}};
    obj = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:data];

    XCTAssertNil(obj);
}

- (void)testNSNullVauesChangedToNil {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"template_id": [NSNull null],
                                   @"subject_template": @"a",
                                   @"body_template": @"b",
                                   }
                           };
    MAVERemoteConfigurationClientEmail *obj = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:dict];
    // should be nil, not nsnull
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.templateID);
}

- (void)testTextFillsInTemplate {
    id templatingUtilsMock = OCMClassMock([MAVETemplatingUtils class]);
    NSString *subjectTemplate = @"{{ customData.foo }}";
    NSString *bodyTemplate = @"{{ customData.bar }}";
    OCMExpect([templatingUtilsMock interpolateWithSingletonDataTemplateString:subjectTemplate]).andReturn(@"bar1");
    OCMExpect([templatingUtilsMock interpolateWithSingletonDataTemplateString:bodyTemplate]).andReturn(@"bar2");

    MAVERemoteConfigurationClientEmail *clientEmailConfig = [[MAVERemoteConfigurationClientEmail alloc] init];
    clientEmailConfig.subjectTemplate = subjectTemplate;
    clientEmailConfig.bodyTemplate = bodyTemplate;

    NSString *subject = [clientEmailConfig subject];
    NSString *body = [clientEmailConfig body];

    OCMVerifyAll(templatingUtilsMock);
    XCTAssertEqualObjects(subject, @"bar1");
    XCTAssertEqualObjects(body, @"bar2");
}

@end
