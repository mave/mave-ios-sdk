//
//  MAVERemoteConfigurationContactsPrePromptTemplateTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/29/14.
//
//

#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationContactsPrePromptTemplate.h"

@interface MAVERemoteConfigurationContactsPrePromptTemplateTests : XCTestCase

@end

@implementation MAVERemoteConfigurationContactsPrePromptTemplateTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationContactsPrePromptTemplate defaultJSONData];
    XCTAssertEqualObjects([defaults objectForKey:@"template_id"], @"default");
    XCTAssertEqualObjects([defaults objectForKey:@"title"], @"Access your contacts?");
    XCTAssertTrue([[defaults objectForKey:@"enabled"] boolValue]);
    XCTAssertEqualObjects([defaults objectForKey:@"message"], @"We need to access your contacts to suggest people to invite.");
    XCTAssertEqualObjects([defaults objectForKey:@"cancel_button_copy"], @"No thanks");
    XCTAssertEqualObjects([defaults objectForKey:@"accept_button_copy"], @"Sounds good");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationContactsPrePromptTemplate *config =
        [[MAVERemoteConfigurationContactsPrePromptTemplate alloc]
         initWithDictionary:[MAVERemoteConfigurationContactsPrePromptTemplate defaultJSONData]];
    XCTAssertEqualObjects(config.templateID, @"default");
    XCTAssertEqual(config.enabled, YES);
    XCTAssertEqualObjects(config.title, @"Access your contacts?");
    XCTAssertEqualObjects(config.message, @"We need to access your contacts to suggest people to invite.");
    XCTAssertEqualObjects(config.cancelButtonCopy, @"No thanks");
    XCTAssertEqualObjects(config.acceptButtonCopy, @"Sounds good");
}

@end
