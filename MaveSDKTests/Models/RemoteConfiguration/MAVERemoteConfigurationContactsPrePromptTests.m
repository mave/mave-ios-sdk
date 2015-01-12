//
//  MAVERemoteConfigurationContactsPrePromptTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/29/14.
//
//

#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationContactsPrePrompt.h"

@interface MAVERemoteConfigurationContactsPrePromptTests : XCTestCase

@end

@implementation MAVERemoteConfigurationContactsPrePromptTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationContactsPrePrompt defaultJSONData];
    XCTAssertTrue([[defaults objectForKey:@"enabled"] boolValue]);
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");
    XCTAssertEqualObjects([template objectForKey:@"title"], @"Access your contacts?");
    XCTAssertEqualObjects([template objectForKey:@"message"], @"We need to access your contacts to suggest people to invite.");
    XCTAssertEqualObjects([template objectForKey:@"cancel_button_copy"], @"No thanks");
    XCTAssertEqualObjects([template objectForKey:@"accept_button_copy"], @"Sounds good");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationContactsPrePrompt *config =
        [[MAVERemoteConfigurationContactsPrePrompt alloc]
         initWithDictionary:[MAVERemoteConfigurationContactsPrePrompt defaultJSONData]];
    XCTAssertEqualObjects(config.templateID, @"0");
    XCTAssertEqual(config.enabled, YES);
    XCTAssertEqualObjects(config.title, @"Access your contacts?");
    XCTAssertEqualObjects(config.message, @"We need to access your contacts to suggest people to invite.");
    XCTAssertEqualObjects(config.cancelButtonCopy, @"No thanks");
    XCTAssertEqualObjects(config.acceptButtonCopy, @"Sounds good");
}

@end
