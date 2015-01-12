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
#import "MAVEAPIInterface.h"

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
    MaveSDK *mave = [MaveSDK sharedInstance];
    XCTAssertEqualObjects(mave.appId, @"foo123");
    XCTAssertNotNil(mave.displayOptions);
    XCTAssertNil(mave.defaultSMSMessageText);
    XCTAssertNotNil(mave.appDeviceID);
    XCTAssertNotNil(mave.remoteConfigurationBuilder);
    XCTAssertNotNil(mave.shareTokenBuilder);
    XCTAssertNotNil(mave.invitePageChooser);
}


- (void)testSharedInstanceIsShared {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk1 = [MaveSDK sharedInstance];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk2 = [MaveSDK sharedInstance];
    
    // Test pointer to same object
    XCTAssertTrue(gk1 == gk2);
}

- (void)testResetSharedInstanceResetsUserDataButNotAppDeviceID {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    NSString *appDeviceID1 = [MaveSDK sharedInstance].appDeviceID;
    [MaveSDK sharedInstance].userData = [[MAVEUserData alloc] init];
    [MaveSDK sharedInstance].userData.userID = @"blah";

    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertNil([MaveSDK sharedInstance].userData.userID);
    XCTAssertEqualObjects(appDeviceID1, [MaveSDK sharedInstance].appDeviceID);
}

- (void)testSetupSharedInstanceTriggersAppOpenEvent {
    id mock = OCMClassMock([MaveSDK class]);
    OCMStub([mock alloc]).andReturn(mock);
    OCMStub([mock initWithAppId:[OCMArg any]]).andReturn(mock);
    
    OCMExpect([mock trackAppOpen]);
    
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    
    OCMVerifyAll(mock);
    // explicitly stop mocking b/c it's a singleton and won't get cleaned up
    [mock stopMocking];
}

- (void)testGetReferringUser {
    // Just ensure that the method on mock manager gets called with our block
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *mave = [MaveSDK sharedInstance];
    id mockAPIInterface = OCMPartialMock(mave.APIInterface);
    void (^emptyReferringUserBlock)(MAVEUserData *userData) = ^void(MAVEUserData *userData) {};
    OCMExpect([mockAPIInterface getReferringUser:emptyReferringUserBlock]);
    
    [mave getReferringUser:emptyReferringUserBlock];
    
    OCMVerifyAll(mockAPIInterface);
}

- (void)testIdentifyUser {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:@"100" firstName:@"Dan" lastName:@"Foo" email:@"dan@example.com" phone:@"18085551234"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        NSUInteger numInvitesSent) {};
    id mockAPIInterface = [OCMockObject mockForClass:[MAVEAPIInterface class]];
    gk.APIInterface = mockAPIInterface;
    OCMExpect([mockAPIInterface identifyUser]);

    [gk identifyUser:userData];

    OCMVerifyAll(mockAPIInterface);
    XCTAssertEqualObjects(gk.userData, userData);
}

- (void)testIdentifyUserInvalidDoesntMakeNetworkRequest {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVEUserData *userData = [[MAVEUserData alloc] init];
    userData.userID = @"1";  // no first name
    id mockAPIInterface = OCMClassMock([MAVEAPIInterface class]);
    MaveSDK *mave = [MaveSDK sharedInstance];
    mave.APIInterface = mockAPIInterface;
    [[mockAPIInterface reject] identifyUser];
    
    [mave identifyUser:userData];
    
    OCMVerifyAll(mockAPIInterface);
    XCTAssertEqualObjects(mave.userData, userData);
}

- (void)testIdentifyAnonymousUser {
    id userDataMock = OCMClassMock([MAVEUserData class]);
    OCMExpect([userDataMock alloc]).andReturn(userDataMock);
    OCMExpect([userDataMock initAutomaticallyFromDeviceName]).andReturn(userDataMock);

    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock identifyUser:userDataMock]);

    [[MaveSDK sharedInstance] identifyAnonymousUser];

    OCMVerifyAll(userDataMock);
    OCMVerifyAll(maveMock);
}

- (void)testValidateLibrarySetupFailsWithNoApplicationID {
    [MaveSDK setupSharedInstanceWithApplicationID:nil];
    MaveSDK *gk = [MaveSDK sharedInstance];
    [gk identifyAnonymousUser];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        NSUInteger numInvitesSent) {};
    NSError *err = [gk validateLibrarySetup];
    XCTAssertEqualObjects(err.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, 5);
    NSArray *errors = [err.userInfo objectForKey:@"messages"];
    XCTAssertEqual([errors count], 1);
    XCTAssertEqualObjects([errors objectAtIndex:0], @"applicationID is nil");
}

- (void)testIsSetupOkFailsWithNilUserData {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        NSUInteger numInvitesSent) {};
    [gk identifyUser:nil];
    NSError *err = [gk validateLibrarySetup];
    XCTAssertEqualObjects(err.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, 5);
    NSArray *errors = [err.userInfo objectForKey:@"messages"];
    XCTAssertEqual([errors count], 1);
    XCTAssertEqualObjects([errors objectAtIndex:0], @"identifyUser: (or identifyAnonymousUser) method not called");
}

- (void)testIsSetupOkFailsWithNoDismissalBlock {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
    [gk identifyAnonymousUser];
    // never set dismissal block so it's nil
    NSError *err = [gk validateLibrarySetup];
    XCTAssertEqualObjects(err.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(err.code, 5);
    NSArray *errors = [err.userInfo objectForKey:@"messages"];
    XCTAssertEqual([errors count], 1);
    XCTAssertEqualObjects([errors objectAtIndex:0], @"invite page dismiss block was nil");
}

- (void)testIsSetupOkSucceedsWithMinimumRequiredFields {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *gk = [MaveSDK sharedInstance];
        [gk identifyUser:[[MAVEUserData alloc] initWithUserID:@"100" firstName:@"Dan" lastName:nil email:nil phone:nil]];
    gk.invitePageDismissalBlock = ^void(UIViewController *vc,
                                        NSUInteger numInvitesSent) {};
    NSError *err = [gk validateLibrarySetup];
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
                          dismissalBlock:^(UIViewController *viewController,
                                           NSUInteger numberOfInvitesSent) {
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
    gk.userData = nil;

    NSError *error;
    UIViewController *vc =
        [gk invitePageWithDefaultMessage:@"tmp"
                              setupError:&error
                          dismissalBlock:^(UIViewController *viewController,
                                           NSUInteger numberOfInvitesSent) {
    }];
    XCTAssertNil(vc);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(gk.defaultSMSMessageText, nil);
    XCTAssertEqualObjects(error.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqual(error.code, 5);
}

- (void)testTrackAppOpen {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *mave = [MaveSDK sharedInstance];
    id mockAPIInterface = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([mockAPIInterface trackAppOpen]);
    [mave trackAppOpen];
    OCMVerifyAll(mockAPIInterface);
}

- (void)testTrackSignup {
    MAVEUserData *userData = [[MAVEUserData alloc] init];
    // Verify the API request is sent
    id mockAPIInterface = [OCMockObject mockForClass:[MAVEAPIInterface class]];
    MaveSDK *mave = [MaveSDK sharedInstance];
    mave.APIInterface = mockAPIInterface;
    mave.userData = userData;
    OCMExpect([mockAPIInterface trackSignup]);
    
    [mave trackSignup];

    OCMVerifyAll(mockAPIInterface);
}

@end