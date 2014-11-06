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
#import "GRKConstants.h"
#import "GRKHTTPManager.h"

@interface GrowthKitTests : XCTestCase

@end

@implementation GrowthKitTests

- (void)setUp {
    [super setUp];
    [GrowthKit resetSharedInstanceForTesting];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetupSharedInstance {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk1 = [GrowthKit sharedInstance];
    XCTAssertEqualObjects(gk1.appId, @"foo123");
    XCTAssertNotNil(gk1.displayOptions);
    #if DEBUG
    NSLog(@"Foolog");
    #else
    NSLog(@"Barlog");
    #endif
}

- (void)testSharedInstanceIsShared {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk1 = [GrowthKit sharedInstance];
    GrowthKit *gk2 = [GrowthKit sharedInstance];
    
    // Test pointer to same object
    XCTAssertTrue(gk1 == gk2);
}

- (void)testSetUserData {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk setUserData:@"123" firstName:@"Foo" lastName:@"Jones"];
    
    XCTAssertEqualObjects(gk.currentUserId, @"123");
    XCTAssertEqualObjects(gk.currentUserFirstName, @"Foo");
    XCTAssertEqualObjects(gk.currentUserLastName, @"Jones");
}

- (void)testIsSetupOkFailsWithNoApplicationID {
    [GrowthKit setupSharedInstanceWithApplicationID:nil];
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk setUserData:@"123" firstName:@"Foo" lastName:@"Jones"];
    NSError *err = [gk validateSetup];
    XCTAssertEqualObjects(err.domain, GRK_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, GRKValidationErrorApplicationIDNotSetCode);
}

- (void)testIsSetupOkFailsWithNoUserID {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk setUserData:nil firstName:@"Foo" lastName:@"Jones"];
    NSError *err = [gk validateSetup];
    XCTAssertEqualObjects(err.domain, GRK_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, GRKValidationErrorUserIDNotSetCode);
}

- (void)testIsSetupOkFailsWithNoFirstName {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk setUserData:@"2" firstName:nil lastName:@"Jones"];
    NSError *err = [gk validateSetup];
    XCTAssertEqualObjects(err.domain, GRK_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, GRKValidationErrorUserNameNotSetCode);
}

- (void)testIsSetupOkSucceedsWithMinimumRequiredFields {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk setUserData:@"1" firstName:nil lastName:nil];
    NSError *err = [gk validateSetup];
    XCTAssertNil(err);
}

- (void)testInvitePageViewControllerNoErrorIfUserDataSet {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk setUserData:@"123" firstName:@"Foo" lastName:@"Jones"];

    NSError *error;
    UIViewController *vc = [gk invitePageViewControllerWithDelegate:nil
                                                    validationError:&error];
    XCTAssertNotNil(vc);
    XCTAssertNil(error);
}

- (void)testInvitePageViewControllerErrorIfValidationError {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk = [GrowthKit sharedInstance];
    // user ID is nil
    [gk setUserData:nil firstName:@"Foo" lastName:@"Jones"];

    NSError *error;
    UIViewController *vc = [gk invitePageViewControllerWithDelegate:nil
                                                    validationError:&error];
    XCTAssertNil(vc);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, GRK_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(error.code, GRKValidationErrorUserIDNotSetCode);
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
    [[mockManager expect] sendUserSignupNotificationWithUserID:userId firstName:firstName lastName:lastName  email:email phone:phone];

    [gk registerNewUserSignup:userId firstName:firstName lastName:lastName email:email phone:phone];

    [mockManager verify];

    // Verify the user data fields are set on the object
    XCTAssertEqualObjects(gk.currentUserId, userId);
    XCTAssertEqualObjects(gk.currentUserFirstName, firstName);
    XCTAssertEqualObjects(gk.currentUserLastName, lastName);
}

@end