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

@implementation MAVERemoteConfigurationTests {
    Method _originalUserDefaultsMethod;
    Method _newUserDefaultsMethod;
}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfiguration defaultJSONData];
    XCTAssertEqualObjects([defaults objectForKey:@"enable_contacts_pre_prompt"], @YES);

    XCTAssertNotNil([defaults objectForKey:@"contacts_pre_prompt_template"]);
    XCTAssertEqualObjects([defaults objectForKey:@"contacts_pre_prompt_template"],
                          [MAVERemoteConfigurationContactsPrePromptTemplate defaultJSONData]);
}

- (void)testInitFromDefaultData {
    MAVERemoteConfiguration *config =
        [[MAVERemoteConfiguration alloc] initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    XCTAssertTrue(config.enableContactsPrePrompt);
    XCTAssertNotNil(config.contactsPrePromptTemplate);
}

@end
