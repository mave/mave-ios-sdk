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
    XCTAssertEqualObjects([template objectForKey:@"title"], @"Use address book?");
    XCTAssertEqualObjects([template objectForKey:@"message"], @"This allows you to select friends from your address book to invite.");
    XCTAssertEqualObjects([template objectForKey:@"cancel_button_copy"], @"Not now");
    XCTAssertEqualObjects([template objectForKey:@"accept_button_copy"], @"OK");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationContactsPrePrompt *config =
        [[MAVERemoteConfigurationContactsPrePrompt alloc]
         initWithDictionary:[MAVERemoteConfigurationContactsPrePrompt defaultJSONData]];
    XCTAssertEqualObjects(config.templateID, @"0");
    XCTAssertEqual(config.enabled, YES);
    XCTAssertEqualObjects(config.title, @"Use address book?");
    XCTAssertEqualObjects(config.message, @"This allows you to select friends from your address book to invite.");
    XCTAssertEqualObjects(config.cancelButtonCopy, @"Not now");
    XCTAssertEqualObjects(config.acceptButtonCopy, @"OK");
}

- (void)testInitWhenDisabledTemplateEmpty {
    NSDictionary *data = @{@"enabled": @0, @"template": [NSNull null]};

    MAVERemoteConfigurationContactsPrePrompt *config = [[MAVERemoteConfigurationContactsPrePrompt alloc] initWithDictionary:data];

    XCTAssertNotNil(config);
    XCTAssertFalse(config.enabled);
    XCTAssertNil(config.templateID);
    XCTAssertNil(config.title);
    XCTAssertNil(config.message);
    // ... etc
}

@end
