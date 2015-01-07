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

    // Swizzle the key name so tests don't overwrite dev data
    _originalUserDefaultsMethod = class_getClassMethod([MAVERemoteConfiguration class], @selector(userDefaultsKey));
    _newUserDefaultsMethod = class_getClassMethod([self class], @selector(fakeUserDefaultsKeyName));
    method_exchangeImplementations(_originalUserDefaultsMethod,
                                   _newUserDefaultsMethod);
}

- (void)tearDown {
    // clean up and un-swizzle
    [[NSUserDefaults standardUserDefaults]
     removeObjectForKey:[MAVERemoteConfiguration userDefaultsKey]];
    method_exchangeImplementations(_newUserDefaultsMethod,
                                   _originalUserDefaultsMethod);
    [super tearDown];
}
+ (NSString *)fakeUserDefaultsKeyName {
    return @"MAVEUserDefaultsTESTSKeyRemoteConfiguration";
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

///
/// Serialization tests
///
- (void)testSaveAndLoadValidJSONDataUserDefaults {
    XCTAssertEqualObjects([MAVERemoteConfiguration userDefaultsKey],
                          @"MAVEUserDefaultsTESTSKeyRemoteConfiguration");

    // try all kinds of property list data
    NSNumber *randomInt = [NSNumber numberWithInt:arc4random_uniform(74)];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@{@"data": @[@1, @YES, @"foo"]} forKey:@"foo"];
    [data setObject:randomInt forKey:@"randomint"];

    [MAVERemoteConfiguration saveJSONDataToUserDefaults:data];
    NSDictionary *returnedData = [MAVERemoteConfiguration loadJSONDataFromUserDefaults];
    XCTAssertNotNil(returnedData);
    XCTAssertEqualObjects(returnedData, data);
}

- (void)testDefaultJSONDataIfSavedData {
    NSDictionary *data = @{@"foo": @2};
    [MAVERemoteConfiguration saveJSONDataToUserDefaults:data];

    NSDictionary *returnedData = [MAVERemoteConfiguration defaultJSONData];

    XCTAssertEqualObjects(returnedData, data);
}

- (void)testDefaultJSONDataIfNoSavedData {
    NSDictionary *defaultData = [MAVERemoteConfiguration defaultDefaultJSONData];
    NSDictionary *returnedData = [MAVERemoteConfiguration defaultJSONData];

    XCTAssertNotNil(defaultData);
    XCTAssertEqualObjects(returnedData, defaultData);
}

@end
