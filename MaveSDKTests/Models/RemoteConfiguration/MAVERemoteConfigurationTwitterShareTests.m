//
//  MAVERemoteConfigurationTwitterShareTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVERemoteConfigurationTwitterShare.h"
#import "MAVETemplatingUtils.h"
#import "MAVESharer.h"

@interface MAVERemoteConfigurationTwitterShareTests : XCTestCase

@end

@implementation MAVERemoteConfigurationTwitterShareTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationTwitterShare defaultJSONData];
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertNotNil(template);

    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");
    XCTAssertEqualObjects([template objectForKey:@"copy_template"], @"I love DemoApp. Try it out {{ link }}");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationTwitterShare *obj = [[MAVERemoteConfigurationTwitterShare alloc] initWithDictionary:[MAVERemoteConfigurationTwitterShare defaultJSONData]];

    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.textTemplate, @"I love DemoApp. Try it out {{ link }}");
}

- (void)testInitFailsIfTemplateMalformed {
    // missing the "copy" parameter
    NSDictionary *data = @{@"template": @{@"template_id": @"foo"}};
    MAVERemoteConfigurationTwitterShare *obj = [[MAVERemoteConfigurationTwitterShare alloc] initWithDictionary:data];
    XCTAssertNil(obj);

    data = @{@"template": @{@"template_id": @"foo", @"copy_template": [NSNull null]}};
    obj = [[MAVERemoteConfigurationTwitterShare alloc] initWithDictionary:data];
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
    MAVERemoteConfigurationTwitterShare *obj = [[MAVERemoteConfigurationTwitterShare alloc] initWithDictionary:dict];
    // should be nil, not nsnull
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.templateID);
}

- (void)testTextFillsInTemplate {
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock shareLinkWithSubRouteLetter:@"t"]).andReturn(@"fakeLink");

    id templatingUtilsMock = OCMClassMock([MAVETemplatingUtils class]);
    NSString *templateString = @"some text";
    OCMExpect([templatingUtilsMock interpolateTemplateString:templateString withUser:[OCMArg any] link:@"fakeLink"]).andReturn(@"bar1");

    MAVERemoteConfigurationTwitterShare *twitterShareConfig = [[MAVERemoteConfigurationTwitterShare alloc] init];
    twitterShareConfig.textTemplate = templateString;

    NSString *output = [twitterShareConfig text];

    OCMVerifyAll(templatingUtilsMock);
    OCMVerifyAll(sharerMock);
    XCTAssertEqualObjects(output, @"bar1");
}

@end
