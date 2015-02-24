//
//  MAVERemoteConfigurationInvitePageTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/10/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationContactsInvitePage.h"

@interface MAVERemoteConfigurationInvitePageTests : XCTestCase

@end

@implementation MAVERemoteConfigurationInvitePageTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultJSON {
    NSDictionary *defaults = [MAVERemoteConfigurationContactsInvitePage defaultJSONData];

    XCTAssertTrue([[defaults objectForKey:@"enabled"] boolValue]);
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");

    XCTAssertNil([template objectForKey:@"explanation_copy"]);
    XCTAssertFalse([[template objectForKey:@"suggested_invites_enabled"] boolValue]);
}

- (void)testInitWithDefaultData {
    MAVERemoteConfigurationContactsInvitePage *obj = [[MAVERemoteConfigurationContactsInvitePage alloc]
        initWithDictionary:[
            MAVERemoteConfigurationContactsInvitePage defaultJSONData]];
    XCTAssertTrue(obj.enabled);
    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertNil(obj.explanationCopy);
    XCTAssertFalse(obj.suggestedInvitesEnabled);
}

- (void)testInitFailsIfEnabledKeyIsMissing {
    // init the normal values dict but leave "enabled" empty
    NSDictionary *defaultDict = [MAVERemoteConfigurationContactsInvitePage defaultJSONData];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[defaultDict objectForKey:@"template"] forKey:@"template"];

    MAVERemoteConfigurationContactsInvitePage *obj = [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:dict];

    XCTAssertNil(obj);
}

- (void)testInitSucceedsIfTemplateValid {
    NSDictionary *dict = @{
        @"enabled": @YES,
        @"template": @{
            @"template_id": @"1",
            @"explanation_copy": @"some copy",
            @"suggested_invites_enabled": @YES,
        }
    };

    MAVERemoteConfigurationContactsInvitePage *obj =
        [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:dict];

    XCTAssertNotNil(obj);
    XCTAssertEqualObjects(obj.templateID, @"1");
    XCTAssertEqualObjects(obj.explanationCopy, @"some copy");
    XCTAssertTrue(obj.suggestedInvitesEnabled);
}

- (void)testInitSucceedsIfTemplateEmpty {
    // if template empty
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{}
    };
    MAVERemoteConfigurationContactsInvitePage *obj = [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:dict];
    XCTAssertNotNil(obj);

    // Or if nsnull values
    dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"template_id": [NSNull null],
                                   @"explanation_copy": [NSNull null],
                                   @"suggested_invites_enabled": [NSNull null],
                            }
                           };
    obj = [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:dict];
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.templateID);
    XCTAssertNil(obj.explanationCopy);
    XCTAssertFalse(obj.suggestedInvitesEnabled);
}

- (void)testNSNullVauesChangedToNil {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                @"template_id": [NSNull null],
                                @"explanation_copy": [NSNull null],
                            }
    };
    MAVERemoteConfigurationContactsInvitePage *obj = [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:dict];
    // should be nil, not nsnull
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.templateID);
    XCTAssertNotEqualObjects(obj.templateID, [NSNull null]);
    XCTAssertNil(obj.explanationCopy);
    XCTAssertNotEqualObjects(obj.explanationCopy, [NSNull null]);
}

- (void)testInitSuccessIfNoTemplateButEnabledFalse {
    NSDictionary *dict = @{@"enabled": @NO, @"template": [NSNull null]};
    MAVERemoteConfigurationContactsInvitePage *obj = [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:dict];

    XCTAssertNotNil(obj);
    XCTAssertFalse(obj.enabled);
    XCTAssertNil(obj.templateID);
}

@end
