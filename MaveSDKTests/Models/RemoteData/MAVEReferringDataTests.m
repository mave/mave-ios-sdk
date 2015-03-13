//
//  MAVEReferringDataTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/26/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEReferringData.h"
#import "MAVERemoteObjectBuilder_Internal.h"
#import "MaveSDK.h"

@interface MAVEReferringDataTests : XCTestCase

@end

@implementation MAVEReferringDataTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaultData = [MAVEReferringData defaultData];
    NSDictionary *expected = @{@"referring_user": [NSNull null],
                               @"current_user": [NSNull null],
                               @"custom_data": @{}};
    XCTAssertEqualObjects(defaultData, expected);
}

- (void)testInitWithDefaultData {
    MAVEReferringData *obj = [[MAVEReferringData alloc] initWithDictionary:[MAVEReferringData defaultData]];
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.referringUser);
    XCTAssertNil(obj.currentUser);
    XCTAssertEqualObjects(obj.customData, @{});
}

- (void)testInitWithOtherInvalidData {
    NSDictionary *data = @{@"referring_user": @{@"foobar asdfasdf asdf adf": @(1),
                                                @"user_id": @""},
                           @"current_user": @"Not a dictionary"};
    MAVEReferringData *obj = [[MAVEReferringData alloc] initWithDictionary:data];
    XCTAssertNotNil(obj);
    XCTAssertEqualObjects(obj.referringUser.userID, @"");
    XCTAssertNil(obj.currentUser.phone);
    XCTAssertEqualObjects(obj.customData, @{});
}

- (void)testInitWithNonDefaultButValidDictionary {
    NSDictionary *customData = @{@"foo": @"bar"};
    NSDictionary *referringUserData = @{@"user_id": @"1",
                                        @"first_name": @"Dan",
                                        @"random_key_will_be_ignored": @"adfasdf"};
    NSDictionary *currentUserData = @{@"phone": @"+12125551234"};
    NSDictionary *data = @{@"referring_user": referringUserData,
                           @"current_user": currentUserData,
                           @"custom_data": customData};
    MAVEReferringData *obj = [[MAVEReferringData alloc] initWithDictionary:data];
    XCTAssertNotNil(obj);
    XCTAssertEqualObjects(obj.referringUser.userID, [referringUserData objectForKey:@"user_id"]);
    XCTAssertEqualObjects(obj.referringUser.firstName, [referringUserData objectForKey:@"first_name"]);
    XCTAssertEqualObjects(obj.referringUser.lastName, nil);
    XCTAssertEqualObjects(obj.currentUser.userID, nil);
    XCTAssertEqualObjects(obj.currentUser.phone, [currentUserData objectForKey:@"phone"]);
    XCTAssertEqualObjects(obj.customData, customData);
}

- (void)testRemoteBuilderNoPreFetch {
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject] getReferringData:[OCMArg any]];

    MAVERemoteObjectBuilder *remoteBuilder = [MAVEReferringData remoteBuilderNoPreFetch];
    XCTAssertEqualObjects(remoteBuilder.classToCreate, [MAVEReferringData class]);
    XCTAssertNotNil(remoteBuilder.promise);
    XCTAssertEqualObjects(remoteBuilder.defaultData, [MAVEReferringData defaultData]);
    OCMVerifyAll(apiInterfaceMock);
}

@end
