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
#import "MAVERemoteConfigurationContactsPrePromptTemplate.h"

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
    XCTAssertNotNil([defaults objectForKey:@"contacts_pre_prompt_template"]);
    XCTAssertEqualObjects([defaults objectForKey:@"contacts_pre_prompt_template"],
                          [MAVERemoteConfigurationContactsPrePromptTemplate defaultJSONData]);
}

- (void)testInitFromDefaultData {
    MAVERemoteConfiguration *config =
        [[MAVERemoteConfiguration alloc] initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    XCTAssertNotNil(config.contactsPrePromptTemplate);
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
