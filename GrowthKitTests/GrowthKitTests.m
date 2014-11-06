//
//  GrowthKitTests.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <objc/runtime.h>
#import "GrowthKit.h"
#import "GrowthKit_Internal.h"
#import "GRKUserData.h"
#import "GRKConstants.h"
#import "GRKHTTPManager.h"

@interface GrowthKitTests : XCTestCase

@end

@implementation GrowthKitTests {
    BOOL _fakeAppLaunchWasTriggered;
}

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
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk2 = [GrowthKit sharedInstance];
    
    // Test pointer to same object
    XCTAssertTrue(gk1 == gk2);
}

- (void)testSetupSharedInstanceTriggersAppOpenEvent {
    // Swizzle methods to check that calling our setup shared instance method also triggers
    // a track app launch event
    Method ogMethod = class_getInstanceMethod([GRKHTTPManager class], @selector(sendApplicationLaunchNotification));
    Method mockMethod = class_getInstanceMethod([self class], @selector(fakeSendApplicationLaunchNotification));
    method_exchangeImplementations(ogMethod, mockMethod);
    
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertEqual(_didCallFakeSendApplicationLaunchNotification, YES);
    
    method_exchangeImplementations(mockMethod, ogMethod);

}

static BOOL _didCallFakeSendApplicationLaunchNotification = NO;
- (void)fakeSendApplicationLaunchNotification {
    _didCallFakeSendApplicationLaunchNotification = YES;
}

- (void)testIdentifyUser {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GRKUserData *userData = [[GRKUserData alloc] initWithUserID:@"100" firstName:@"Dan" lastName:@"Foo" email:@"dan@example.com" phone:@"18085551234"];
    id mockManager = [OCMockObject mockForClass:[GRKHTTPManager class]];
    GrowthKit *gk = [GrowthKit sharedInstance];
    gk.HTTPManager = mockManager;
    [[mockManager expect] identifyUserRequest:userData];

    [gk identifyUser:userData];

    [mockManager verify];
    XCTAssertEqualObjects(gk.userData, userData);
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
    [gk setUserData:@"1" firstName:@"Dan" lastName:nil];
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

- (void)testTrackAppOpen {
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    GrowthKit *gk = [GrowthKit sharedInstance];
    id httpManagerMock = [OCMockObject partialMockForObject: [GrowthKit sharedInstance].HTTPManager];
    [[httpManagerMock expect] sendApplicationLaunchNotification];
    [gk trackAppOpen];
    [httpManagerMock verify];
}

- (void)testTrackSignup {
    GRKUserData *userData = [[GRKUserData alloc] init];
    // Verify the API request is sent
    id mockManager = [OCMockObject mockForClass:[GRKHTTPManager class]];
    GrowthKit *gk = [GrowthKit sharedInstance];
    gk.HTTPManager = mockManager;
    [[mockManager expect] trackSignupRequest:userData];

    [mockManager verify];
}

@end