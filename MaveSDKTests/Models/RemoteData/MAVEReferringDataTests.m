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

- (void)testRemoteBuilderFulfillSuccess {
    NSDictionary *responseData = @{@"referring_user": @{@"user_id": @"123", @"first_name": @"Fooz"},
                                   @"current_user": @{@"phone": @"+18085556712"}};

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock getReferringData:[OCMArg checkWithBlock:^BOOL(id obj) {
        ((MAVEHTTPCompletionBlock)obj)(nil, responseData);
        return YES;
    }]]);

    MAVERemoteObjectBuilder *remoteBuilder = [MAVEReferringData remoteBuilderWithPreFetch];
    MAVEReferringData *referringData = [remoteBuilder createObjectSynchronousWithTimeout:0.25];

    XCTAssertEqualObjects(referringData.referringUser.userID, @"123");
    XCTAssertEqualObjects(referringData.referringUser.firstName, @"Fooz");
    XCTAssertEqualObjects(referringData.currentUser.phone, @"+18085556712");
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testRemoteBuilderFulfillFailure {
    NSError *responseError = [[NSError alloc] init];  // doesn't matter what the error is

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock getReferringData:[OCMArg checkWithBlock:^BOOL(id obj) {
        ((MAVEHTTPCompletionBlock)obj)(responseError, nil);
        return YES;
    }]]);

    MAVERemoteObjectBuilder *remoteBuilder = [MAVEReferringData remoteBuilderWithPreFetch];
    MAVEReferringData *referringData = [remoteBuilder createObjectSynchronousWithTimeout:0.25];
    // will fall back to default data which is nil
    XCTAssertEqualObjects(referringData.referringUser.userID, nil);
    XCTAssertEqualObjects(referringData.referringUser.firstName, nil);
    XCTAssertEqualObjects(referringData.currentUser.phone, nil);
    OCMVerifyAll(apiInterfaceMock);
}

@end
