//
//  MAVERemoteConfigurationCustomSharePageTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/13/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
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
    XCTAssertEqualObjects([defaults objectForKey:@"invite_link_domain"], [NSNull null]);
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");

    // The actual app name here comes from the bundle name, this test always runs in
    // the context of the demo app
    XCTAssertEqualObjects([template objectForKey:@"explanation_copy_template"],
                          @"Share DemoApp with friends");
}

- (void)testInitWithDefaultData {
    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:[MAVERemoteConfigurationCustomSharePage defaultJSONData]];
    XCTAssertTrue(obj.enabled);
    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.explanationCopy,
                          @"Share DemoApp with friends");
    XCTAssertEqualObjects(obj.inviteLinkDomain, nil);
}

- (void)testInviteConfigWithInviteLinkDomain {
    NSString *domain = @"https://example.com";
    NSMutableDictionary *opts = [[NSMutableDictionary alloc] init];
    [opts addEntriesFromDictionary:[MAVERemoteConfigurationCustomSharePage defaultJSONData]];
    [opts setObject:domain forKey:@"invite_link_domain"];

    MAVERemoteConfigurationCustomSharePage *config = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:opts];
    XCTAssertEqualObjects(config.inviteLinkDomain, domain);
}

- (void)testExplanationCopyInterpolatesTemplate {
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.promoCode = @"1234foo";
    OCMStub([maveMock userData]).andReturn(user);

    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] init];
    obj.explanationCopyTemplate = @"Hey use my code {{ user.promoCode }}!";

    XCTAssertEqualObjects(obj.explanationCopy, @"Hey use my code 1234foo!");
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

    // or if required fields are nsnull
    dict = @{ @"enabled": @YES, @"template": @{
                    @"template_id": @"foo",
                    @"explanation_copy_template": [NSNull null],
            }
    };
    obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:dict];
    XCTAssertNil(obj);
}

- (void)testInitSucceedsIfTemplateIDEmpty {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"explanation_copy_template": @"",
                                   }
                           };

    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:dict];

    XCTAssertNotNil(obj);
    XCTAssertEqualObjects(obj.explanationCopy, @"");
}

- (void)testNSNullConvertedToNil {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"explanation_copy_template": @"foo",
                                   @"template_id": [NSNull null],
                                   }
                           };

    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:dict];

    XCTAssertNotNil(obj);
    XCTAssertNil(obj.templateID);
}

- (void)testInitSuccessIfNoTemplateButEnabledFalse {
    NSDictionary *dict = @{@"enabled": @NO, @"template": [NSNull null]};
    MAVERemoteConfigurationCustomSharePage *obj = [[MAVERemoteConfigurationCustomSharePage alloc] initWithDictionary:dict];
    
    XCTAssertNotNil(obj);
    XCTAssertFalse(obj.enabled);
    XCTAssertNil(obj.templateID);
}

@end
