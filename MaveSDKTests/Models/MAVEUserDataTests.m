//
//  MAVEUserDataTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/6/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEUserData.h"
#import "MaveSDK.h"
#import "MAVEClientPropertyUtils.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEUserDataTests : XCTestCase

@end

@implementation MAVEUserDataTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithShortUserData {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithUserID:@"id1" firstName:@"fi" lastName:@"la"];
    XCTAssertEqualObjects(ud.userID, @"id1");
    XCTAssertEqualObjects(ud.firstName, @"fi");
    XCTAssertEqualObjects(ud.lastName, @"la");
    XCTAssertNil(ud.email);
    XCTAssertNil(ud.phone);
    XCTAssertFalse(ud.isSetAutomaticallyFromDevice);
    XCTAssertTrue(ud.wrapInviteLink);
    XCTAssertNil(ud.customData);
    XCTAssertNil(ud.promoCode);
}

- (void)testInitWithFullUserData {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithUserID:@"id1" firstName:@"fi" lastName:@"la" email:@"em" phone:@"ph"];
    XCTAssertEqualObjects(ud.userID, @"id1");
    XCTAssertEqualObjects(ud.firstName, @"fi");
    XCTAssertEqualObjects(ud.lastName, @"la");
    XCTAssertEqualObjects(ud.email, @"em");
    XCTAssertEqualObjects(ud.phone, @"ph");
    XCTAssertFalse(ud.isSetAutomaticallyFromDevice);
    XCTAssertTrue(ud.wrapInviteLink);
    XCTAssertNil(ud.customData);
    XCTAssertNil(ud.promoCode);
}

- (void)initAndSetExtraFields {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithUserID:@"id1" firstName:@"fi" lastName:@"la"];
    ud.email = @"em";
    ud.phone = @"ph";
    ud.picture = [NSURL URLWithString:@"http://example.com/pic"];
    XCTAssertEqualObjects(ud.userID, @"id1");
    XCTAssertEqualObjects(ud.firstName, @"fi");
    XCTAssertEqualObjects(ud.lastName, @"la");
    XCTAssertEqualObjects(ud.email, @"em");
    XCTAssertEqualObjects(ud.phone, @"ph");
    XCTAssertEqualObjects([ud.picture absoluteString], @"http://example.com/pic");
    XCTAssertFalse(ud.isSetAutomaticallyFromDevice);
    XCTAssertTrue(ud.wrapInviteLink);
    XCTAssertNil(ud.customData);
    XCTAssertNil(ud.promoCode);
}

- (void)testInitWithDictionary {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithDictionary:@{
            @"user_id": @"id1",
            @"first_name": @"fi",
            @"last_name": @"la",
            @"email": @"em",
            @"phone": @"ph",
            @"picture": @"http://example.com/pic",
            @"promo_code": @"pc",
    }];
    XCTAssertEqualObjects(ud.userID, @"id1");
    XCTAssertEqualObjects(ud.firstName, @"fi");
    XCTAssertEqualObjects(ud.lastName, @"la");
    XCTAssertEqualObjects(ud.email, @"em");
    XCTAssertEqualObjects(ud.phone, @"ph");
    XCTAssertEqualObjects(ud.promoCode, @"pc");
    XCTAssertEqualObjects([ud.picture absoluteString], @"http://example.com/pic");
    XCTAssertFalse(ud.isSetAutomaticallyFromDevice);
    XCTAssertTrue(ud.wrapInviteLink);
    XCTAssertNil(ud.customData);
}

- (void)testInitWithDictionaryInvalidURL {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithDictionary:@{
        @"picture": [NSNull null],
    }];
    XCTAssertNil(ud.picture);
}

- (void)testInitAutomatically {
    NSString *expectedAppDeviceID = [MaveSDK sharedInstance].appDeviceID;
    XCTAssertNotNil(expectedAppDeviceID);

    // Should parse the device name to figure out name
    id propertyMock = OCMClassMock([MAVEClientPropertyUtils class]);
    OCMStub([propertyMock deviceName]).andReturn(@"Danny Cosson's iPhone");
    MAVEUserData *user = [[MAVEUserData alloc] initAutomaticallyFromDeviceName];
    XCTAssertEqualObjects(user.userID, expectedAppDeviceID);
    XCTAssertEqualObjects(user.firstName, @"Danny");
    XCTAssertEqualObjects(user.lastName, @"Cosson");
    XCTAssertNil(user.phone);
    XCTAssertNil(user.email);
    XCTAssertNil(user.promoCode);
    XCTAssertTrue(user.isSetAutomaticallyFromDevice);
    XCTAssertTrue(user.wrapInviteLink);
    XCTAssertNil(user.customData);
}

- (void)testIsUserInfoOkToSendServerSideSMS {
    MAVEUserData *user = [[MAVEUserData alloc] init];
    XCTAssertFalse([user isUserInfoOkToSendServerSideSMS]);

    user = [[MAVEUserData alloc] init];
    user.userID = @"balsdf";
    XCTAssertFalse([user isUserInfoOkToSendServerSideSMS]);

    user = [[MAVEUserData alloc] init];
    user.userID = @"balsdf";
    user.firstName = @"blahasdfasdf";
    XCTAssertTrue([user isUserInfoOkToSendServerSideSMS]);

    user = nil;
    XCTAssertFalse([user isUserInfoOkToSendServerSideSMS]);
}

- (void)testEmptyStringNameNotOkForInvites {
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"foo"
                                                    firstName:@""
                                                     lastName:nil
                                                        email:nil
                                                        phone:nil];
    XCTAssertFalse([user isUserInfoOkToSendServerSideSMS]);
}

- (void)testToDictionaryAllNils {
    MAVEUserData *ud = [[MAVEUserData alloc] init];
    NSDictionary *dict = [ud toDictionary];
    XCTAssertEqualObjects(dict, @{});
}

- (void)testToDictionaryNoNils {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithUserID:@"id1" firstName:@"fi" lastName:@"la"];
    ud.email = @"em";
    ud.phone = @"ph";
    ud.picture = [NSURL URLWithString:@"http://example.com/pic"];
    ud.promoCode = @"pc";
    NSDictionary *expected = @{@"user_id": @"id1",
                               @"first_name": @"fi",
                               @"last_name": @"la",
                               @"email": @"em",
                               @"phone": @"ph",
                               @"picture": @"http://example.com/pic",
                               @"promo_code": @"pc"};
    XCTAssertEqualObjects([ud toDictionary], expected);
}

- (void)testToDictionaryIDOnly {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithUserID:@"id5" firstName:@"fi" lastName:@"la" email:@"em" phone:@"ph"];
    NSDictionary *expected = @{@"user_id": @"id5"};
    XCTAssertEqualObjects([ud toDictionaryIDOnly], expected);
}

- (void)testSerializeLinkDetailsWhenSet {
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Foo" lastName:@"Bar"];
    user.inviteLinkDestinationURL = @"https://example.com/blah";
    user.wrapInviteLink = YES;
    user.customData = @{@"foo": @"bar"};

    NSDictionary *linkDetails = [user serializeLinkDetails];
    XCTAssertEqual([linkDetails count], 3);
    XCTAssertEqualObjects(linkDetails[@"link_destination"], @"https://example.com/blah");
    XCTAssertEqualObjects(linkDetails[@"custom_data"], @{@"foo": @"bar"});
    XCTAssertEqualObjects(linkDetails[@"wrap_invite_link"], @YES);
}

- (void)testSerializeLinkDetailsEmpty {
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Foo" lastName:@"Bar"];
    NSDictionary *linkDetails = [user serializeLinkDetails];
    XCTAssertEqual([linkDetails count], 3);
    XCTAssertEqualObjects(linkDetails[@"link_destination"], [NSNull null]);
    XCTAssertEqualObjects(linkDetails[@"custom_data"], @{});
    XCTAssertEqualObjects(linkDetails[@"wrap_invite_link"], @YES);
    MAVEUserData *otherUser = [[MAVEUserData alloc] initWithUserID:@"2" firstName:@"blah" lastName:nil];
    XCTAssertEqualObjects(linkDetails, [otherUser serializeLinkDetails]);
}

- (void)testFullName {
    MAVEUserData *ud = [[MAVEUserData alloc] init];
    ud.firstName = @"Foo";
    ud.lastName = @"Bar";
    XCTAssertEqualObjects(ud.fullName, @"Foo Bar");
}

- (void)testFullNameWhenEmpty {
    MAVEUserData *ud = [[MAVEUserData alloc] init];
    XCTAssertEqualObjects(ud.fullName, nil);
}

- (void)testFullNameWhenFirstNameOnly {
    MAVEUserData *ud = [[MAVEUserData alloc] init];
    ud.firstName = @"Foo";
    XCTAssertEqualObjects(ud.fullName, @"Foo");
}

@end
