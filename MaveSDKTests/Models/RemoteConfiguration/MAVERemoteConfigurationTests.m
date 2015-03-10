//
//  MAVERemoteConfigurationTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/29/14.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#include <stdlib.h>
#import <objc/runtime.h>
#import "MAVEConstants.h"
#import "MAVERemoteConfiguration.h"
#import "MAVERemoteConfigurationContactsPrePrompt.h"
#import "MAVERemoteConfigurationContactsInvitePage.h"
#import "MAVERemoteConfigurationCustomSharePage.h"
#import "MAVERemoteConfigurationClientSMS.h"

@interface MAVERemoteConfigurationTests : XCTestCase

@end

@implementation MAVERemoteConfigurationTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfiguration defaultJSONData];
    XCTAssertNotNil([defaults objectForKey:@"invite_page"]);
    XCTAssertEqualObjects([defaults objectForKey:@"invite_page"],
                          [MAVERemoteConfigurationInvitePage defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"contacts_sync"]);
    XCTAssertEqualObjects([defaults objectForKey:@"contacts_sync"],
                          [MAVERemoteConfigurationContactsSync defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"contacts_pre_permission_prompt"]);
    XCTAssertEqualObjects([defaults objectForKey:@"contacts_pre_permission_prompt"],
                          [MAVERemoteConfigurationContactsPrePrompt defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"contacts_invite_page"]);
    XCTAssertEqualObjects([defaults objectForKey:@"contacts_invite_page"],
                           [MAVERemoteConfigurationContactsInvitePage defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"share_page"]);
    XCTAssertEqualObjects([defaults objectForKey:@"share_page"],
                          [MAVERemoteConfigurationCustomSharePage defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"server_sms"]);
    XCTAssertEqualObjects([defaults objectForKey:@"server_sms"],
                          [MAVERemoteConfigurationServerSMS defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"client_sms"]);
    XCTAssertEqualObjects([defaults objectForKey:@"client_sms"],
                          [MAVERemoteConfigurationClientSMS defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"client_email"]);
    XCTAssertEqualObjects([defaults objectForKey:@"client_email"],
                          [MAVERemoteConfigurationClientEmail defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"facebook_share"]);
    XCTAssertEqualObjects([defaults objectForKey:@"facebook_share"],
                          [MAVERemoteConfigurationFacebookShare defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"twitter_share"]);
    XCTAssertEqualObjects([defaults objectForKey:@"twitter_share"],
                          [MAVERemoteConfigurationTwitterShare defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"clipboard_share"]);
    XCTAssertEqualObjects([defaults objectForKey:@"clipboard_share"],
                          [MAVERemoteConfigurationClipboardShare defaultJSONData]);
}

- (void)testInitFromDefaultData {
    MAVERemoteConfiguration *config =
        [[MAVERemoteConfiguration alloc] initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    XCTAssertNotNil(config.invitePage);
    XCTAssertNotNil(config.contactsSync);
    XCTAssertNotNil(config.contactsPrePrompt);
    XCTAssertNotNil(config.contactsInvitePage);
    XCTAssertNotNil(config.customSharePage);
    XCTAssertNotNil(config.serverSMS);
    XCTAssertNotNil(config.clientSMS);
    XCTAssertNotNil(config.clientEmail);
    XCTAssertNotNil(config.facebookShare);
    XCTAssertNotNil(config.twitterShare);
    XCTAssertNotNil(config.clipboardShare);
}

- (void)testInitFailsIfSubConfigurationObjectsFail {
    NSDictionary *dict = @{};
    MAVERemoteConfiguration *obj = [[MAVERemoteConfiguration alloc] initWithDictionary:dict];

    XCTAssertNil(obj);
}

- (void)testRemoteBuilder {
    id mock = OCMClassMock([MAVERemoteObjectBuilder class]);

    OCMExpect([mock alloc]).andReturn(mock);
    OCMExpect([mock initWithClassToCreate:[MAVERemoteConfiguration class]
                            preFetchBlock:[OCMArg any]
                              defaultData:[MAVERemoteConfiguration defaultJSONData]
        saveIfSuccessfulToUserDefaultsKey:MAVEUserDefaultsKeyRemoteConfiguration
                   preferLocallySavedData:NO]).andReturn(mock);
    id returnedVal = [MAVERemoteConfiguration remoteBuilder];

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(returnedVal, mock);
    [mock stopMocking];
}

@end
