//
//  MAVETemplatingUtilsTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/24/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVETemplatingUtils.h"
#import "MaveSDK.h"

@interface MAVETemplatingUtilsTests : XCTestCase

@end

@implementation MAVETemplatingUtilsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInterpolateTemplateStringNoInterpolation {
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Foo" lastName:@"Bar"];
    user.customData = @{@"foo_field": @"blah"};
    NSString *template = @"Hello there";
    NSString *output = [MAVETemplatingUtils interpolateTemplateString:template withUser:user];

    NSString *expected = template;
    XCTAssertEqualObjects(output, expected);
}

- (void)testInterpolateTemplateStringNoInterpolationNils {
    NSString *output = [MAVETemplatingUtils interpolateTemplateString:@"Foo" withUser:nil];

    XCTAssertEqualObjects(output, @"Foo");
}

- (void)testInterpolateTemplateStringNil {
    NSString *output = [MAVETemplatingUtils interpolateTemplateString:nil withUser:nil];
    XCTAssertNil(output);
}

- (void)testInterpolateTemplateStringSimpleWithUserAndCustomData {
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Foo" lastName:@"Bar"];
    user.customData = @{@"foo_field": @"blah"};
    NSString *template = @"{{ user.firstName }} is \"{{customData.foo_field}}\"";
    NSString *output = [MAVETemplatingUtils interpolateTemplateString:template withUser:user];

    NSString *expected = @"Foo is \"blah\"";
    XCTAssertEqualObjects(output, expected);
}

- (void)testInterpolateTemplateStringAllUserFields {
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Foo" lastName:@"Bar"];
    user.customData = @{};
    user.promoCode = @"123foo";
    NSString *template = @"{{ user.userID }} {{ user.firstName }} {{ user.lastName }} '{{ user.fullName }}' {{ user.promoCode }}";
    NSString *output = [MAVETemplatingUtils interpolateTemplateString:template withUser:user];

    NSString *expected = @"1 Foo Bar 'Foo Bar' 123foo";
    XCTAssertEqualObjects(output, expected);
}

- (void)testInterpolateTemplateStringMissingStringLeavesEmpty {
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Foo" lastName:@"Bar"];
    user.customData = nil;
    NSString *template = @"{{ user.firstName }} is not \"{{ firstName }}\"";
    NSString *output = [MAVETemplatingUtils interpolateTemplateString:template withUser:user];

    NSString *expected = @"Foo is not \"\"";
    XCTAssertEqualObjects(output, expected);
}

- (void)testConvertValueToStringFromVariousTypes {
    id a = @2;
    id b = @(2.129312);
    id c = @(YES);
    id d = [NSNull null];
    id e = @"string";
    id f = [[MAVEUserData alloc] init];

    XCTAssertEqualObjects([MAVETemplatingUtils convertValueToString:a], @"2");
    XCTAssertEqualObjects([MAVETemplatingUtils convertValueToString:b], @"2.129312");
    XCTAssertEqualObjects([MAVETemplatingUtils convertValueToString:c], @"1");
    XCTAssertEqualObjects([MAVETemplatingUtils convertValueToString:d], @"<null>");
    XCTAssertEqualObjects([MAVETemplatingUtils convertValueToString:e], @"string");
    XCTAssertNil([MAVETemplatingUtils convertValueToString:f]);
}

- (void)testInterpolateTemplateStringConvertsValuesToStrings {
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.customData = @{@"a": @19, @"b": @(19.55), @"c": @(YES), @"d": [NSNull null], @"e": @"string", @"f": [[MAVEUserData alloc] init]};
    NSString *templateString = @"a {{ customData.a }} b {{ customData.b }} c {{ customData.c }} d {{ customData.d }} e {{ customData.e }} f {{ customData.f }}";

    NSString *output = [MAVETemplatingUtils interpolateTemplateString:templateString withUser:user];
    NSString *expected = @"a 19 b 19.55 c 1 d <null> e string f ";
    XCTAssertEqualObjects(output, expected);
}

- (void)testInterpolateTemplateStringSkipsNonStringKeys {
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.customData = @{@(19): @"foo"};
    NSString *output = [MAVETemplatingUtils interpolateTemplateString:@"{{ customData.19 }}" withUser:user];
    XCTAssertEqualObjects(output, @"");
}

- (void)testAppendLinkVariableToTemplateStringIfNeededWhenNeeded {
    NSString *tmpl0 = @"Simple string";
    NSString *exp0 = @"Simple string {{ link }}";
    NSString *output0 = [MAVETemplatingUtils appendLinkVariableToTemplateStringIfNeeded:tmpl0];
    XCTAssertEqualObjects(output0, exp0);

    NSString *tmpl1 = @"String without {{ link variable";
    NSString *exp1 = @"String without {{ link variable {{ link }}";
    NSString *output1 = [MAVETemplatingUtils appendLinkVariableToTemplateStringIfNeeded:tmpl1];
    XCTAssertEqualObjects(output1, exp1);

    // don't add an extra string if it ends in whitespace
    NSString *tmpl2 = @"String ending in whitespace ";
    NSString *exp2 = @"String ending in whitespace {{ link }}";
    NSString *output2 = [MAVETemplatingUtils appendLinkVariableToTemplateStringIfNeeded:tmpl2];
    XCTAssertEqualObjects(output2, exp2);

    // doesn't break for empty string or nil
    XCTAssertEqualObjects([MAVETemplatingUtils appendLinkVariableToTemplateStringIfNeeded:@""], @"{{ link }}");
    XCTAssertEqualObjects([MAVETemplatingUtils appendLinkVariableToTemplateStringIfNeeded:nil], @"{{ link }}");

}

- (void)testAppendLinkVariableToTemplateStringIfNeededWhenNotNeeded {
    NSString *tmpl0 = @"Some string with {{  link}} variable";
    NSString *output = [MAVETemplatingUtils appendLinkVariableToTemplateStringIfNeeded:tmpl0];
    XCTAssertEqualObjects(tmpl0, output);
}

- (void)testInterpolateWithSingletonData {
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Foo" lastName:@"Bar"];
    user.customData = @{@"other_field": @"blahz"};
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock userData]).andReturn(user);

    NSString *template = @"hello {{ user.fullName }}, something else {{ customData.other_field }}";
    NSString *output = [MAVETemplatingUtils interpolateWithSingletonDataTemplateString:template];

    OCMVerifyAll(maveMock);
    NSString *expected = @"hello Foo Bar, something else blahz";
    XCTAssertEqualObjects(output, expected);
}

@end
