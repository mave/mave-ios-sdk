//
//  MAVEClientPropertyUtilsTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/30/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MaveSDK_Internal.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVEConstants.h"
#import "MAVEIDUtils.h"
#import "MAVENameParsingUtils.h"

// make screen bounds writable so we can stub the mainscreen for testing
@interface UIScreen (BoundsWritable)
@property (nonatomic, readwrite) CGRect bounds;
@end

@interface MAVEClientPropertyUtilsTests : XCTestCase

@end

@implementation MAVEClientPropertyUtilsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEncodedAutomaticClientProperties {
    NSString *encProperties = [MAVEClientPropertyUtils encodedAutomaticClientProperties];
    NSDictionary *properties = [MAVEClientPropertyUtils base64DecodeJSONString:encProperties];
    // All properties should exist
    XCTAssertEqual([properties count], 12);
}

- (void)testEncodedContextProperties {
    [MaveSDK sharedInstance].inviteContext = @"foobartestcontext";
    XCTAssertNotNil([MaveSDK sharedInstance].userData.userID);
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    id builderMock = OCMClassMock([MAVERemoteObjectBuilder class]);
    OCMExpect([builderMock object]).andReturn(remoteConfig);
    [MaveSDK sharedInstance].remoteConfigurationBuilder = builderMock;

    NSString *base64Properties = [MAVEClientPropertyUtils encodedContextProperties];
    NSDictionary *properties = [MAVEClientPropertyUtils base64DecodeJSONString:base64Properties];
    XCTAssertEqual([properties count], 11);
    XCTAssertEqualObjects([properties objectForKey:@"invite_context"], @"foobartestcontext");
    XCTAssertEqualObjects([properties objectForKey:@"user_id"], [MaveSDK sharedInstance].userData.userID);

    XCTAssertEqualObjects([properties objectForKey:@"contacts_pre_permission_prompt_template_id"], @"0");
    XCTAssertEqualObjects([properties objectForKey:@"contacts_invite_page_template_id"], @"0");
    XCTAssertEqualObjects([properties objectForKey:@"share_page_template_id"], @"0");
    XCTAssertEqualObjects([properties objectForKey:@"server_sms_template_id"], @"0");
    XCTAssertEqualObjects([properties objectForKey:@"client_sms_template_id"], @"0");
    XCTAssertEqualObjects([properties objectForKey:@"client_email_template_id"], @"0");
    XCTAssertEqualObjects([properties objectForKey:@"facebook_share_template_id"], @"0");
    XCTAssertEqualObjects([properties objectForKey:@"twitter_share_template_id"], @"0");
    XCTAssertEqualObjects([properties objectForKey:@"clipboard_share_template_id"], @"0");
    OCMVerifyAll(builderMock);
}

- (void)testEncodedContextPropertiesNull {
    [MaveSDK sharedInstance].inviteContext = @"foobartestcontext";
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
    remoteConfig.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] init];
    remoteConfig.contactsInvitePage.templateID = nil;

    id builderMock = OCMClassMock([MAVERemoteObjectBuilder class]);
    OCMExpect([builderMock object]).andReturn(remoteConfig);
    [MaveSDK sharedInstance].remoteConfigurationBuilder = builderMock;

    NSString *base64Properties = [MAVEClientPropertyUtils encodedContextProperties];
    NSDictionary *properties = [MAVEClientPropertyUtils base64DecodeJSONString:base64Properties];
    NSString *propertiesString = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:base64Properties options:0] encoding:NSUTF8StringEncoding];

    // Check that the json string that gets set explicitly has the "null" value
    NSString *expectedNullString = @"\"contacts_invite_page_template_id\":null";
    XCTAssertNotEqual([propertiesString rangeOfString:expectedNullString].location,
                      NSNotFound);
    XCTAssertEqual([properties count], 11);
}


- (void)testUserAgentDeviceString {
    NSString *iosVersionStr = [[UIDevice currentDevice].systemVersion
                               stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSString *expectedUA = [NSString stringWithFormat:
                            @"(iPhone; CPU iPhone OS %@ like Mac OS X)",
                            iosVersionStr];
    NSString *ua = [MAVEClientPropertyUtils userAgentDeviceString];
    XCTAssertEqualObjects(ua, expectedUA);
    
}

// Test formatting screen size - should convert the screen size to a string of the
// format "AxB" that does not differ if we are in landscape mode and rounds decimals
- (void)testFormattedScreenSizeSimple {
    id mock = OCMPartialMock([UIScreen mainScreen]);
    OCMStub([mock bounds]).andReturn(CGRectMake(0, 0, 10, 10));
    XCTAssertEqualObjects([MAVEClientPropertyUtils formattedScreenSize], @"10x10");
}
- (void)testFormattedScreenSizeHeightLarger {
    id mock = OCMPartialMock([UIScreen mainScreen]);
    OCMStub([mock bounds]).andReturn(CGRectMake(0, 0, 10, 20));
    XCTAssertEqualObjects([MAVEClientPropertyUtils formattedScreenSize], @"10x20");
}
- (void)testFormattedScreenSizeWidthLarger {
    id mock = OCMPartialMock([UIScreen mainScreen]);
    OCMStub([mock bounds]).andReturn(CGRectMake(0, 0, 20, 10));
    XCTAssertEqualObjects([MAVEClientPropertyUtils formattedScreenSize], @"10x20");
}
- (void)testFormattedScreenSizeRoundDecimal {
    id mock = OCMPartialMock([UIScreen mainScreen]);
    OCMStub([mock bounds]).andReturn(CGRectMake(0, 0, 10.5001, 10.4999));
    XCTAssertEqualObjects([MAVEClientPropertyUtils formattedScreenSize], @"10x11");
}

- (void)testBase64EncodeDictionary {
    NSDictionary *dict = @{@"foo": @YES};
    NSString *b64 = [MAVEClientPropertyUtils base64EncodeDictionary:dict];
    XCTAssertEqualObjects([MAVEClientPropertyUtils base64DecodeJSONString:b64], dict);
}

- (void)testUrlSafeBase64EncodeData {
    // use a string that will have the special characters - and _
    NSString *s1 = [@"" stringByAppendingFormat:@"%c%c%c",
                    (char)0xff, (char)0xff, (char)0xfe];
    NSData *data1 = [s1 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *expectedS1Encoded = @"w7_Dv8O-";

    // and use a string that would be padded with '='
    NSString *s2 = @"food";
    NSData *data2 = [s2 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *expectedS2Encoded = @"Zm9vZA";

    NSString *encoded1 = [MAVEClientPropertyUtils urlSafeBase64EncodeAndStripData:data1];

    NSString *encoded2 = [MAVEClientPropertyUtils urlSafeBase64EncodeAndStripData:data2];

    XCTAssertEqualObjects(encoded1, expectedS1Encoded);
    XCTAssertEqualObjects(encoded2, expectedS2Encoded);
}

- (void)testUrlSafeBase64EncodedEmpty {
    NSData *data1 = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([MAVEClientPropertyUtils urlSafeBase64EncodeAndStripData:data1], @"");
    XCTAssertEqualObjects([MAVEClientPropertyUtils urlSafeBase64EncodeAndStripData:nil], @"");
}

- (void)testUrlSafeBase64EncodeAppIDWhenBigInteger {
    [MaveSDK sharedInstance].appId = @"202834210204166";
    XCTAssertEqualObjects([MAVEClientPropertyUtils urlSafeBase64ApplicationID],
                          @"AAC4egUMKgY");

    [MaveSDK sharedInstance].appId = @"0";
    XCTAssertEqualObjects([MAVEClientPropertyUtils urlSafeBase64ApplicationID],
                          @"AAAAAAAAAAA");
}

- (void)testUrlSafeBase64EncodeAppIDWhenString {
    [MaveSDK sharedInstance].appId = @"10afdkjl3";
    XCTAssertEqualObjects([MAVEClientPropertyUtils urlSafeBase64ApplicationID],
                          @"MTBhZmRramwz");
    [MaveSDK sharedInstance].appId = @"";
    XCTAssertEqualObjects([MAVEClientPropertyUtils urlSafeBase64ApplicationID],
                          @"");
}


///
/// Test inidividual properties are rereasonable values
///

- (void)testAppName {
    // For this app, it's DemoApp
    XCTAssertEqualObjects([MAVEClientPropertyUtils appName], @"DemoApp");
}

- (void)testAppRelease {
    NSString *appRelease = [MAVEClientPropertyUtils appRelease];
    XCTAssertNotNil(appRelease);
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"^[0-9]+\\.[0-9]+\\.[0-9]$" options:0 error:nil];
    NSArray *matches = [regex matchesInString:appRelease options:0 range:NSMakeRange(0, [appRelease length])];
    XCTAssertEqual([matches count], 1);
}

- (void)testAppVersion {
    XCTAssertGreaterThan([[MAVEClientPropertyUtils appVersion] intValue], 0);
}

- (void)testCountryCode {
    XCTAssertEqualObjects([MAVEClientPropertyUtils countryCode], @"US");
}

- (void)testDeviceName {
    XCTAssertEqualObjects([MAVEClientPropertyUtils deviceName], @"iPhone Simulator");
}

- (void)testDeviceUsersFullName {
    id nameParserMock = OCMClassMock([MAVENameParsingUtils class]);
    OCMStub([nameParserMock fillFirstName:[OCMArg setTo:@"Foo"]
                                 lastName:[OCMArg setTo:@"Bar"]
                           fromDeviceName:@"iPhone Simulator"]);
    XCTAssertEqualObjects([MAVEClientPropertyUtils deviceUsersFullName],
                          @"Foo Bar");
}

- (void)testDeviceUsersFirstName {
    id nameParserMock = OCMClassMock([MAVENameParsingUtils class]);
    OCMStub([nameParserMock fillFirstName:[OCMArg setTo:@"Foo"]
                                 lastName:[OCMArg setTo:@"NONE"]
                           fromDeviceName:@"iPhone Simulator"]);
    XCTAssertEqualObjects([MAVEClientPropertyUtils deviceUsersFirstName], @"Foo");
}

- (void)testDeviceUsersLastName {
    id nameParserMock = OCMClassMock([MAVENameParsingUtils class]);
    OCMStub([nameParserMock fillFirstName:[OCMArg setTo:@"NONE"]
                                 lastName:[OCMArg setTo:@"Bar"]
                           fromDeviceName:@"iPhone Simulator"]);
    XCTAssertEqualObjects([MAVEClientPropertyUtils deviceUsersLastName], @"Bar");
}

- (void)testLanguage {
    XCTAssertEqualObjects([MAVEClientPropertyUtils language], @"en");
}

- (void)testCarrier {
    // on simulator carrier will be null which we turn to unknown
    XCTAssertEqualObjects([MAVEClientPropertyUtils carrier], @"Unknown");
}

- (void)testAppDeviceID {
    id idUtilsMock = OCMClassMock([MAVEIDUtils class]);
    OCMStub([idUtilsMock loadOrCreateNewAppDeviceID]).andReturn(@"foobarid");
    XCTAssertEqualObjects([MAVEClientPropertyUtils appDeviceID], @"foobarid");
}

- (void)testMaveVersion {
    XCTAssertNotNil([MAVEClientPropertyUtils maveVersion]);
    XCTAssertEqualObjects([MAVEClientPropertyUtils maveVersion],
                          MAVESDKVersion);
}

- (void)testManufacturer {
    XCTAssertEqualObjects([MAVEClientPropertyUtils manufacturer], @"Apple");
}

- (void)testModel {
    // Simulator model for whatever reason is just the architecture
    XCTAssertEqualObjects([MAVEClientPropertyUtils model], @"x86_64");
}

- (void)testOS {
    XCTAssertEqualObjects([MAVEClientPropertyUtils os], @"iPhone OS");
}

- (void)testOSVersion {
    NSString *osVersion = [MAVEClientPropertyUtils osVersion];
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"^[7-8]+\\.[0-4]$" options:0 error:nil];
    NSArray *matches = [regex matchesInString:osVersion options:0 range:NSMakeRange(0, [osVersion length])];
    XCTAssertEqual([matches count], 1);
}

@end
