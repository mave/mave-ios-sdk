//
//  MAVERemoteConfigurationTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/29/14.
//
//

#import <XCTest/XCTest.h>
#import "MAVERemoteConfiguration.h"
#import "MAVERemoteConfigurationContactsPrePromptTemplate.h"

@interface MAVERemoteConfigurationTests : XCTestCase

@end

@implementation MAVERemoteConfigurationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
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
