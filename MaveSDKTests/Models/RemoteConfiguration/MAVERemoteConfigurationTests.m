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
#import "MAVERemoteConfiguration.h"
#import "MAVERemoteConfigurationContactsPrePrompt.h"
#import "MAVERemoteConfigurationContactsInvitePage.h"
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
    XCTAssertNotNil([defaults objectForKey:@"contacts_pre_permission_prompt"]);
    XCTAssertEqualObjects([defaults objectForKey:@"contacts_pre_permission_prompt"],
                          [MAVERemoteConfigurationContactsPrePrompt defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"contacts_invite_page"]);
    XCTAssertEqualObjects([defaults objectForKey:@"contacts_invite_page"],
                           [MAVERemoteConfigurationContactsInvitePage defaultJSONData]);
    XCTAssertNotNil([defaults objectForKey:@"client_sms"]);
    XCTAssertEqualObjects([defaults objectForKey:@"client_sms"],
                          [MAVERemoteConfigurationClientSMS defaultJSONData]);
}

- (void)testInitFromDefaultData {
    MAVERemoteConfiguration *config =
        [[MAVERemoteConfiguration alloc] initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    XCTAssertNotNil(config.contactsPrePrompt);
    XCTAssertNotNil(config.contactsInvitePage);
    XCTAssertNotNil(config.clientSMS);
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
