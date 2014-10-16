//
//  GrowthKitTests.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "GrowthKit.h"
#import "GRKHTTPManager.h"

@interface GrowthKitTests : XCTestCase

@end

@implementation GrowthKitTests

- (void)setUp {
    [super setUp];
    // reset shared instance
    [GrowthKit setupSharedInstanceWithApplicationID:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetupAndGetSharedInstance{
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk1 = [GrowthKit sharedInstance];
    GrowthKit *gk2 = [GrowthKit sharedInstance];
    
    // Test pointer to same object
    XCTAssertTrue(gk1 == gk2);
    XCTAssertEqualObjects(gk1.appId, @"foo123");
    XCTAssertEqualObjects(gk2.appId,@"foo123");
}

- (void)testSetUserData {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk setUserData:@"123" firstName:@"Foo" lastName:@"Jones"];
    
    XCTAssertEqualObjects(gk.currentUserId, @"123");
    XCTAssertEqualObjects(gk.currentUserFirstName, @"Foo");
    XCTAssertEqualObjects(gk.currentUserLastName, @"Jones");
}

- (void)testReportAppOpen {
    GrowthKit *gk = [GrowthKit sharedInstance];
    id httpManagerMock = [OCMockObject partialMockForObject: [GrowthKit sharedInstance].HTTPManager];
    [[httpManagerMock expect] sendApplicationLaunchNotification];
    [gk registerAppOpen];
    [httpManagerMock verify];
}

- (void)testReportNewUserSignup {
    NSString *userId = @"100";
    NSString *firstName = @"Dan"; NSString *lastName = @"Foo";
    NSString *email = @"dan@example.com"; NSString *phone = @"18085551234";

    // Verify the API request is sent
    id mockManager = [OCMockObject mockForClass:[GRKHTTPManager class]];
    GrowthKit *gk = [GrowthKit sharedInstance];
    gk.HTTPManager = mockManager;
    [[mockManager expect] sendUserSignupNotificationWithUserID:userId email:email phone:phone];

    [gk registerNewUserSignup:userId firstName:firstName lastName:lastName email:email phone:phone];

    [mockManager verify];

    // Verify the user data fields are set on the object
    XCTAssertEqualObjects(gk.currentUserId, userId);
    XCTAssertEqualObjects(gk.currentUserFirstName, firstName);
    XCTAssertEqualObjects(gk.currentUserLastName, lastName);
}

@end