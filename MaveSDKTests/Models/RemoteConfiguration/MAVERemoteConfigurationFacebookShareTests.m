//
//  MAVERemoteConfigurationFacebookShareTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVERemoteConfigurationFacebookShare.h"
#import "MAVETemplatingUtils.h"

@interface MAVERemoteConfigurationFacebookShareTests : XCTestCase

@end

@implementation MAVERemoteConfigurationFacebookShareTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationFacebookShare defaultJSONData];
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertNotNil(template);

    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");
    XCTAssertEqualObjects([template objectForKey:@"initial_text_template"], @"I love DemoApp. You should try it.");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationFacebookShare *obj = [[MAVERemoteConfigurationFacebookShare alloc] initWithDictionary:[MAVERemoteConfigurationFacebookShare defaultJSONData]];

    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.textTemplate, @"I love DemoApp. You should try it.");
}

- (void)testInitFailsIfTemplateMalformed {
    // missing the "copy" parameter
    NSDictionary *data = @{@"template": @{@"template_id": @"foo"}};
    MAVERemoteConfigurationFacebookShare *obj = [[MAVERemoteConfigurationFacebookShare alloc] initWithDictionary:data];
    XCTAssertNil(obj);

    data = @{@"template": @{@"template_id": @"foo", @"initial_text_template": [NSNull null]}};
    obj = [[MAVERemoteConfigurationFacebookShare alloc] initWithDictionary:data];
    XCTAssertNil(obj);
}

- (void)testNSNullVauesChangedToNil {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"template_id": [NSNull null],
                                   @"initial_text_template": @"foo",
                                   }
                           };
    MAVERemoteConfigurationFacebookShare *obj = [[MAVERemoteConfigurationFacebookShare alloc] initWithDictionary:dict];
    // should be nil, not nsnull
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.templateID);
}

- (void)testTextFillsInTemplate {
    id templatingUtilsMock = OCMClassMock([MAVETemplatingUtils class]);
    NSString *templateString = @"some string";
    OCMExpect([templatingUtilsMock interpolateTemplateString:templateString withUser:[OCMArg any] link:nil]).andReturn(@"bar1");

    MAVERemoteConfigurationFacebookShare *facebookShareConfig = [[MAVERemoteConfigurationFacebookShare alloc] init];
    facebookShareConfig.textTemplate = templateString;

    NSString *output = [facebookShareConfig text];

    OCMVerifyAll(templatingUtilsMock);
    XCTAssertEqualObjects(output, @"bar1");
}

@end
