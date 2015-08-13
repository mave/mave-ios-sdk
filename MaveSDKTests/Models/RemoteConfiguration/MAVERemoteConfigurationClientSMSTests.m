//
//  MAVERemoteConfigurationClientSMSTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVERemoteConfigurationClientSMS.h"
#import "MAVETemplatingUtils.h"
#import "MAVESharer.h"

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
    XCTAssertEqualObjects([template objectForKey:@"copy_template"],
                          @"Join me on DemoApp!");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationClientSMS *obj = [[MAVERemoteConfigurationClientSMS alloc] initWithDictionary:[MAVERemoteConfigurationClientSMS defaultJSONData]];

    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.textTemplate, @"Join me on DemoApp!");
}

- (void)testInitFailsIfTemplateMalformed {
    // missing the "text" parameter
    NSDictionary *data = @{@"template": @{@"template_id": @"foo"}};
    MAVERemoteConfigurationClientSMS *obj = [[MAVERemoteConfigurationClientSMS alloc] initWithDictionary:data];

    data = @{@"template": @{@"template_id": @"foo", @"copy_template": [NSNull null]}};
    obj = [[MAVERemoteConfigurationClientSMS alloc] initWithDictionary:data];

    XCTAssertNil(obj);
}

- (void)testNSNullVauesChangedToNil {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"template_id": [NSNull null],
                                   @"copy_template": @"foo",
                                   }
                           };
    MAVERemoteConfigurationClientSMS *obj = [[MAVERemoteConfigurationClientSMS alloc] initWithDictionary:dict];
    // should be nil, not nsnull
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.templateID);
}

- (void)testTextFillsInTemplate {
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock shareLinkWithSubRouteLetter:@"s"]).andReturn(@"fakeLink");

    id templatingUtilsMock = OCMClassMock([MAVETemplatingUtils class]);
    NSString *templateString = @"some template";
    // note: if not link in template string, we don't automatically append one
    // (like we do with server sms)
    OCMExpect([templatingUtilsMock interpolateTemplateString:templateString withUser:[OCMArg any] link:@"fakeLink"]).andReturn(@"bar1");

    MAVERemoteConfigurationClientSMS *clientSMSConfig = [[MAVERemoteConfigurationClientSMS alloc] init];
    clientSMSConfig.textTemplate = templateString;

    NSString *output = [clientSMSConfig text];

    OCMVerifyAll(templatingUtilsMock);
    OCMVerifyAll(sharerMock);
    XCTAssertEqualObjects(output, @"bar1");
}

@end
