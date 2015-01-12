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

- (void)testInitWithUserData {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithUserID:@"id1" firstName:@"fi" lastName:@"la" email:@"em" phone:@"ph"];
    XCTAssertEqualObjects(ud.userID, @"id1");
    XCTAssertEqualObjects(ud.firstName, @"fi");
    XCTAssertEqualObjects(ud.lastName, @"la");
    XCTAssertEqualObjects(ud.email, @"em");
    XCTAssertEqualObjects(ud.phone, @"ph");
}

- (void)testInitWithDictionary {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithDictionary:@{
            @"user_id": @"id1",
            @"first_name": @"fi",
            @"last_name": @"la",
            @"email": @"em",
            @"phone": @"ph",
    }];
    XCTAssertEqualObjects(ud.userID, @"id1");
    XCTAssertEqualObjects(ud.firstName, @"fi");
    XCTAssertEqualObjects(ud.lastName, @"la");
    XCTAssertEqualObjects(ud.email, @"em");
    XCTAssertEqualObjects(ud.phone, @"ph");
}

- (void)testToDictionaryAllNils {
    MAVEUserData *ud = [[MAVEUserData alloc] init];
    NSDictionary *dict = [ud toDictionary];
    XCTAssertEqualObjects(dict, @{});
}

- (void)testToDictionaryNoNils {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithUserID:@"id1" firstName:@"fi" lastName:@"la" email:@"em" phone:@"ph"];
    NSDictionary *expected = @{@"user_id": @"id1",
                               @"first_name": @"fi",
                               @"last_name": @"la",
                               @"email": @"em",
                               @"phone": @"ph"};
    XCTAssertEqualObjects([ud toDictionary], expected);
}

- (void)testToDictionaryIDOnly {
    MAVEUserData *ud = [[MAVEUserData alloc] initWithUserID:@"id5" firstName:@"fi" lastName:@"la" email:@"em" phone:@"ph"];
    NSDictionary *expected = @{@"user_id": @"id5"};
    XCTAssertEqualObjects([ud toDictionaryIDOnly], expected);
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
