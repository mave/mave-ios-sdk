//
//  MAVERemoteConfigurationInvitePageTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationInvitePageChoice.h"

@interface MAVERemoteConfigurationInvitePageChoiceTests : XCTestCase

@end

@implementation MAVERemoteConfigurationInvitePageChoiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultJSON {
    NSDictionary *defaults = [MAVERemoteConfigurationInvitePageChoice defaultJSONData];
    XCTAssertEqual([defaults count], 1);
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertEqual([template count], 2);
    XCTAssertEqualObjects([template objectForKey:@"primary_page"], @"contacts_invite_page");
    XCTAssertEqualObjects([template objectForKey:@"fallback_page"], @"share_page");
}

- (void)testInitWithDefaultData {
    MAVERemoteConfigurationInvitePageChoice *invitePage = [[MAVERemoteConfigurationInvitePageChoice alloc] initWithDictionary:[MAVERemoteConfigurationInvitePageChoice defaultJSONData]];

    XCTAssertEqual(invitePage.primaryPageType, MAVEInvitePageTypeContactsInvitePage);
    XCTAssertEqual(invitePage.fallbackPageType, MAVEInvitePageTypeSharePage);
}

- (void)testInitWithOtherPageOptions {
    NSDictionary *options = @{@"primary_page": @"share_page",
                              @"fallback_page": @"client_sms"};
    options = @{@"template": options};

    MAVERemoteConfigurationInvitePageChoice *invitePage = [[MAVERemoteConfigurationInvitePageChoice alloc] initWithDictionary:options];

    XCTAssertEqual(invitePage.primaryPageType, MAVEInvitePageTypeSharePage);
    XCTAssertEqual(invitePage.fallbackPageType, MAVEInvitePageTypeClientSMS);
}

- (void)testInitWithInvitePageV2 {
    NSDictionary *options = @{@"primary_page": @"contacts_invite_page_v2",
                              @"fallback_page": @"client_sms"};
    options = @{@"template": options};

    MAVERemoteConfigurationInvitePageChoice *invitePage = [[MAVERemoteConfigurationInvitePageChoice alloc] initWithDictionary:options];

    XCTAssertEqual(invitePage.primaryPageType, MAVEInvitePageTypeContactsInvitePageV2);
    XCTAssertEqual(invitePage.fallbackPageType, MAVEInvitePageTypeClientSMS);
}

- (void)testInitWithInvitePageV3 {
    NSDictionary *options = @{@"primary_page": @"contacts_invite_page_v3",
                              @"fallback_page": @"client_sms"};
    options = @{@"template": options};

    MAVERemoteConfigurationInvitePageChoice *invitePage = [[MAVERemoteConfigurationInvitePageChoice alloc] initWithDictionary:options];

    XCTAssertEqual(invitePage.primaryPageType, MAVEInvitePageTypeContactsInvitePageV3);
    XCTAssertEqual(invitePage.fallbackPageType, MAVEInvitePageTypeClientSMS);
}

- (void)testInitWithInvalidOptions {
    NSDictionary *options = @{@"primary_page": @"foo",
                              @"fallback_page": @"bar"};
    options = @{@"template": options};

    MAVERemoteConfigurationInvitePageChoice *invitePage = [[MAVERemoteConfigurationInvitePageChoice alloc] initWithDictionary:options];
    XCTAssertEqual(invitePage.primaryPageType, MAVEInvitePageTypeContactsInvitePage);
    XCTAssertEqual(invitePage.fallbackPageType, MAVEInvitePageTypeSharePage);

    // or init with nil, same thing
    invitePage = [[MAVERemoteConfigurationInvitePageChoice alloc] initWithDictionary:nil];
    XCTAssertEqual(invitePage.primaryPageType, MAVEInvitePageTypeContactsInvitePage);
    XCTAssertEqual(invitePage.fallbackPageType, MAVEInvitePageTypeSharePage);
}

@end
