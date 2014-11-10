//
//  MaveSDKTests.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <objc/runtime.h>
#import "MaveSDK.h"
#import "MaveSDK_Internal.h"
#import "MAVEUserData.h"
#import "MAVEConstants.h"
#import "MAVEHTTPManager.h"

@interface MaveSDKTests : XCTestCase

@end

@implementation MaveSDKTests {
    BOOL _fakeAppLaunchWasTriggered;
}

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetupSharedInstance {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk1 = [MaveSDK sharedInstance];
    XCTAssertEqualObjects(gk1.appId, @"foo123");
    XCTAssertNotNil(gk1.displayOptions);
    XCTAssertNil(gk1.defaultSMSMessageText);
}


- (void)testSharedInstanceIsShared {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk1 = [MaveSDK sharedInstance];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk2 = [MaveSDK sharedInstance];
    
    // Test pointer to same object
    XCTAssertTrue(gk1 == gk2);
}

- (void)testSetupSharedInstanceTriggersAppOpenEvent {
    // Swizzle methods to check that calling our setup shared instance method also triggers
    // a track app launch event
    Method ogMethod = class_getInstanceMethod([MAVEHTTPManager class], @selector(trackAppOpenRequest));
    Method mockMethod = class_getInstanceMethod([self class], @selector(fakeTrackAppOpenRequest));
    method_exchangeImplementations(ogMethod, mockMethod);
    
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertEqual(_didCallFakeTrackAppOpenRequest, YES);
    
    method_exchangeImplementations(mockMethod, ogMethod);

}

static BOOL _didCallFakeTrackAppOpenRequest = NO;
- (void)fakeTrackAppOpenRequest {
    _didCallFakeTrackAppOpenRequest = YES;
}

- (void)testIdentifyUser {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:@"100" firstName:@"Dan" lastName:@"Foo" email:@"dan@example.com" phone:@"18085551234"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        unsigned int numInvitesSent) {};
    id mockManager = [OCMockObject mockForClass:[MAVEHTTPManager class]];
    gk.HTTPManager = mockManager;
    [[mockManager expect] identifyUserRequest:userData];

    [gk identifyUser:userData];

    [mockManager verify];
    XCTAssertEqualObjects(gk.userData, userData);
}

- (void)testIdentifyUserInvalidDoesntMakeNetworkRequest {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVEUserData *userData = [[MAVEUserData alloc] init];
    userData.userID = @"1";  // no first name
    id mockManager = [OCMockObject mockForClass:[MAVEHTTPManager class]];
    MaveSDK *gk = [MaveSDK sharedInstance];
    gk.HTTPManager = mockManager;
    [[mockManager reject] identifyUserRequest:userData];
    
    [gk identifyUser:userData];
    
    [mockManager verify];
    XCTAssertEqualObjects(gk.userData, userData);
}

- (void)testIsSetupOkFailsWithNoApplicationID {
    [MaveSDK setupSharedInstanceWithApplicationID:nil];
    MaveSDK *gk = [MaveSDK sharedInstance];
    [gk identifyUser:[[MAVEUserData alloc] initWithUserID:@"100" firstName:@"Dan" lastName:@"Foo" email:@"dan@example.com" phone:@"18085551234"]];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        unsigned int numInvitesSent) {};
    NSError *err = [gk validateSetup];
    XCTAssertEqualObjects(err.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, MAVEValidationErrorApplicationIDNotSetCode);
}

- (void)testIsSetupOkFailsWithNilUserData {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        unsigned int numInvitesSent) {};
    [gk identifyUser:nil];
    NSError *err = [gk validateSetup];
    XCTAssertEqualObjects(err.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, MAVEValidationErrorUserIDNotSetCode);
}

- (void)testIsSetupOkFailsWithNoUserID {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    [gk identifyUser:[[MAVEUserData alloc] initWithUserID:nil firstName:@"Dan" lastName:@"Foo" email:@"dan@example.com" phone:@"18085551234"]];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        unsigned int numInvitesSent) {};
    NSError *err = [gk validateSetup];
    XCTAssertEqualObjects(err.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, MAVEValidationErrorUserIDNotSetCode);
}

- (void)testIsSetupOkFailsWithNoFirstName {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    [gk identifyUser:[[MAVEUserData alloc] initWithUserID:@"100" firstName:nil lastName:@"Foo" email:@"dan@example.com" phone:@"18085551234"]];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        unsigned int numInvitesSent) {};
    NSError *err = [gk validateSetup];
    XCTAssertEqualObjects(err.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, MAVEValidationErrorUserNameNotSetCode);
}

- (void)testIsSetupOkFailsWithNoDismissalBlock {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    [gk identifyUser:[[MAVEUserData alloc] initWithUserID:@"100" firstName:@"Dan" lastName:@"Foo" email:@"dan@example.com" phone:@"18085551234"]];
    // never set dismissal block so it's nil
    NSError *err = [gk validateSetup];
    XCTAssertEqualObjects(err.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, MAVEValidationErrorDismissalBlockNotSetCode);
}

- (void)testIsSetupOkSucceedsWithMinimumRequiredFields {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
        [gk identifyUser:[[MAVEUserData alloc] initWithUserID:@"100" firstName:@"Dan" lastName:nil email:nil phone:nil]];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        unsigned int numInvitesSent) {};
    NSError *err = [gk validateSetup];
    XCTAssertNil(err);
}

- (void)testInvitePageViewControllerNoErrorIfUserDataSet {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    gk.userData = [[MAVEUserData alloc] init];
    gk.userData.userID = @"123";
    gk.userData.firstName = @"Dan";

    NSError *error;
    __block BOOL blockCalled = NO;
    UIViewController *vc =
        [gk invitePageWithDefaultMessage:@"tmp"
                              setupError:&error
                         completionBlock:^(UIViewController *viewController,
                                           unsigned int numberOfInvitesSent) {
                             blockCalled = YES;
    }];
    XCTAssertNotNil(vc);
    XCTAssertNil(error);
    XCTAssertEqualObjects(gk.defaultSMSMessageText, @"tmp");
    // Assert dismissal block set
    gk.invitePageDismissalBlock(vc, 10);
    XCTAssertTrue(blockCalled);
}

- (void)testInvitePageViewControllerErrorIfValidationError {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    gk.userData = [[MAVEUserData alloc] init];
    // user ID is nil
    gk.userData.firstName = @"Dan";

    NSError *error;
    UIViewController *vc =
        [gk invitePageWithDefaultMessage:@"tmp"
                              setupError:&error
                         completionBlock:^(UIViewController *viewController,
                                           unsigned int numberOfInvitesSent) {
    }];
    XCTAssertNil(vc);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(gk.defaultSMSMessageText, nil);
    XCTAssertEqualObjects(error.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(error.code, MAVEValidationErrorUserIDNotSetCode);
}

- (void)testTrackAppOpen {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    id httpManagerMock = [OCMockObject partialMockForObject: [MaveSDK sharedInstance].HTTPManager];
    [[httpManagerMock expect] trackAppOpenRequest];
    [gk trackAppOpen];
    [httpManagerMock verify];
}

- (void)testTrackSignup {
    MAVEUserData *userData = [[MAVEUserData alloc] init];
    // Verify the API request is sent
    id mockManager = [OCMockObject mockForClass:[MAVEHTTPManager class]];
    MaveSDK *gk = [MaveSDK sharedInstance];
    gk.HTTPManager = mockManager;
    gk.userData = userData;
    [[mockManager expect] trackSignupRequest:userData];
    
    [gk trackSignup];

    [mockManager verify];
}

@end