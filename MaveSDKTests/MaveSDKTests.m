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
#import "MAVEInvitePageChooser.h"
#import "MAVEUserData.h"
#import "MAVEConstants.h"
#import "MAVEAPIInterface.h"
#import "MAVESuggestedInvites.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEABSyncManager(Testing)
+ (NSInteger)valueOfSyncContactsOnceToken;
+ (void)resetSyncContactsOnceTokenForTesting;
@end

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
    [MAVEABSyncManager resetSyncContactsOnceTokenForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];

    MaveSDK *mave = [MaveSDK sharedInstance];
    XCTAssertEqualObjects(mave.appId, @"foo123");
    XCTAssertNotNil(mave.displayOptions);
    XCTAssertEqualObjects(mave.defaultSMSMessageText, mave.remoteConfiguration.serverSMS.text);
    XCTAssertNotNil(mave.appDeviceID);
    XCTAssertNotNil(mave.remoteConfigurationBuilder);
    XCTAssertNotNil(mave.shareTokenBuilder);
    XCTAssertNotNil(mave.addressBookSyncManager);
    XCTAssertNotNil(mave.suggestedInvitesBuilder);
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

// Test getting properties on the mave object
- (void) testRemoteConfiguration {
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    [MaveSDK sharedInstance].remoteConfigurationBuilder = builder;
    id remoteConfig = [[MAVERemoteConfiguration alloc] init];

    id builderMock = OCMPartialMock(builder);
    OCMStub([builderMock createObjectSynchronousWithTimeout:0]).andReturn(remoteConfig);

    XCTAssertEqualObjects([[MaveSDK sharedInstance] remoteConfiguration],
                          remoteConfig);
}

- (void)testSuggestedInvitesWithDelay {
    NSArray *suggestions = @[@"blah", @"foo"];
    MAVESuggestedInvites *suggestedObject = [[MAVESuggestedInvites alloc] init];
    suggestedObject.suggestions = suggestions;

    CGFloat delay = 1.234;
    id builderMock = OCMClassMock([MAVERemoteObjectBuilder class]);
    OCMExpect([builderMock createObjectSynchronousWithTimeout:delay]).andReturn(suggestedObject);
    [MaveSDK sharedInstance].suggestedInvitesBuilder = builderMock;

    NSArray *returnedSuggestions = [[MaveSDK sharedInstance] suggestedInvitesWithDelay:delay];

    XCTAssertEqualObjects(returnedSuggestions, suggestions);
    OCMVerifyAll(builderMock);
}


- (void) testDefaultSMSText {
    MaveSDK *mave = [MaveSDK sharedInstance];

    // can be set in remote config
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
    remoteConfig.serverSMS = [[MAVERemoteConfigurationServerSMS alloc] init];
    remoteConfig.serverSMS.text = @"foo";
    id maveMock = OCMPartialMock(mave);
    OCMStub([maveMock remoteConfiguration]).andReturn(remoteConfig);

    // if set explicitly, return that as explanation text
    mave.defaultSMSMessageText = @"bar";
    XCTAssertEqualObjects(mave.defaultSMSMessageText, @"bar");

    // if not set, return the value from remote config
    mave.defaultSMSMessageText = nil;
    XCTAssertEqualObjects(mave.defaultSMSMessageText, @"foo");
}

- (void)testInviteExplanationCopy {
    MaveSDK *mave = [MaveSDK sharedInstance];
    mave.displayOptions = [[MAVEDisplayOptions alloc] init];

    // can be set in remote config
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
    remoteConfig.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] init];
    remoteConfig.contactsInvitePage.explanationCopy = @"foo";
    id maveMock = OCMPartialMock(mave);
    OCMStub([maveMock remoteConfiguration]).andReturn(remoteConfig);

    // if set explicitly in display options, return that as explanation text
    mave.displayOptions.inviteExplanationCopy = @"bar";
    XCTAssertEqualObjects(mave.inviteExplanationCopy, @"bar");

    // if not set, return the value from remote config
    mave.displayOptions.inviteExplanationCopy = nil;
    XCTAssertEqualObjects(mave.inviteExplanationCopy, @"foo");
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
    MaveSDK *mave = [MaveSDK sharedInstance];
    id mockAPIInterface = [OCMockObject mockForClass:[MAVEAPIInterface class]];
    mave.APIInterface = mockAPIInterface;
    OCMExpect([mockAPIInterface identifyUser]);

    [mave identifyUser:userData];

    OCMVerifyAll(mockAPIInterface);
    XCTAssertEqualObjects(mave.userData, userData);
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

- (void)testSetUserDataPersistsToUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:MAVEUserDefaultsKeyUserData];

    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.firstName = @"aa234";
    [MaveSDK sharedInstance].userData = user;

    NSDictionary *persistedData = [NSKeyedUnarchiver unarchiveObjectWithData:
                                   [defaults objectForKey:MAVEUserDefaultsKeyUserData]];
    XCTAssertNotNil(persistedData);
    MAVEUserData *queriedData = [[MAVEUserData alloc] initWithDictionary:persistedData];
    XCTAssertEqualObjects(queriedData.firstName, @"aa234");
}

- (void)testGetUserDataGetsFromUserDefaultsIfNotSet {
    // Make sure state is reset
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    [MaveSDK sharedInstance].userData = nil;
    [defaults removeObjectForKey:MAVEUserDefaultsKeyUserData];
    XCTAssertNil([MaveSDK sharedInstance].userData);

    // set the user data in user defaults, but it's still nil on the object
    // will be equal to what we persisted to defaults
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.firstName = @"aa235";
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:[user toDictionary]];
    [defaults setObject:archivedData forKey:MAVEUserDefaultsKeyUserData];
    XCTAssertEqualObjects([MaveSDK sharedInstance].userData.firstName, @"aa235");

    // Explicitly set the user data, should be equal to that
    user.firstName = @"aa240";
    [MaveSDK sharedInstance].userData = user;
    XCTAssertEqualObjects([MaveSDK sharedInstance].userData.firstName, @"aa240");
}

- (void)testIsSetupOKFailsWithNoApplicationID {
    [MaveSDK setupSharedInstanceWithApplicationID:nil];
    MaveSDK *mave = [MaveSDK sharedInstance];
    [mave identifyAnonymousUser];
    XCTAssertFalse([mave isSetupOK]);
}

- (void)testIsSetupOkSucceedsWithMinimumRequiredFields {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MaveSDK *mave = [MaveSDK sharedInstance];
    // didn't identify user, but it's ok
    XCTAssertTrue([mave isSetupOK]);
}

# pragma mark - Displaying the invite page
- (void)testPresentInvitePageModally {
    MaveSDK *mave = [MaveSDK sharedInstance];

    id maveMock = OCMPartialMock(mave);
    OCMExpect([maveMock isSetupOK]).andReturn(YES);

    MAVEInvitePageDismissBlock dismissalBlock = ^(UIViewController *viewController, NSUInteger numberOfInvitesSent) {};

    __block UIViewController *returnedController;
    __block BOOL called;
    [mave presentInvitePageModallyWithBlock:^(UIViewController *inviteViewController) {
        returnedController = inviteViewController;
        called = YES;
    } dismissBlock:dismissalBlock inviteContext:@"foocontext"];

    // Returns a navigation controller since this is the present modally variation,
    // and set the necessary properties
    OCMVerifyAll(maveMock);
    XCTAssertEqualObjects(mave.invitePageChooser.navigationPresentedFormat, MAVEInvitePagePresentFormatModal);
    XCTAssertEqualObjects(mave.invitePageChooser.navigationCancelBlock, dismissalBlock);
    XCTAssertEqualObjects(mave.inviteContext, @"foocontext");
    XCTAssertTrue(called);
    XCTAssertNotNil(returnedController);
    XCTAssertTrue([returnedController isKindOfClass:[UINavigationController class]]);
}

- (void)testPresentInvitePageModallyWithError {
    MaveSDK *mave = [MaveSDK sharedInstance];

    id maveMock = OCMPartialMock(mave);
    OCMExpect([maveMock isSetupOK]).andReturn(NO);

    __block BOOL called = NO;
    // dismissal block nil triggers error
    [mave presentInvitePageModallyWithBlock:^(UIViewController *inviteViewController) {
        called = YES;
    } dismissBlock:nil inviteContext:@"foocontext"];

    OCMVerifyAll(maveMock);
    XCTAssertFalse(called);
}

- (void)testPresentInvitePagePush {
    MaveSDK *mave = [MaveSDK sharedInstance];

    id maveMock = OCMPartialMock(mave);
    OCMExpect([maveMock isSetupOK]).andReturn(YES);

    MAVEInvitePageDismissBlock backBlock = ^(UIViewController *viewController, NSUInteger numberOfInvitesSent) {};
    MAVEInvitePageDismissBlock forwardBlock = ^(UIViewController *viewController, NSUInteger numberOfInvitesSent) {};


    __block UIViewController *returnedController;
    __block BOOL called;
    [mave presentInvitePagePushWithBlock:^(UIViewController *inviteController) {
        returnedController = inviteController;
        called = YES;
    }
                               forwardBlock:forwardBlock
                               backBlock:backBlock
                           inviteContext:@"foocontext"];

    // Returns a view controller since this is the present push variation,
    // and set the necessary properties
    OCMVerifyAll(maveMock);
    XCTAssertEqualObjects(mave.invitePageChooser.navigationPresentedFormat, MAVEInvitePagePresentFormatPush);
    XCTAssertNil(mave.invitePageChooser.navigationCancelBlock);
    XCTAssertEqualObjects(mave.invitePageChooser.navigationForwardBlock, forwardBlock);
    XCTAssertEqualObjects(mave.invitePageChooser.navigationBackBlock, backBlock);
    XCTAssertEqualObjects(mave.inviteContext, @"foocontext");
    XCTAssertTrue(called);
    XCTAssertNotNil(returnedController);
    XCTAssertFalse([returnedController isKindOfClass:[UINavigationController class]]);
}

- (void)testPresentInvitePagePushWithError {
    MaveSDK *mave = [MaveSDK sharedInstance];

    id maveMock = OCMPartialMock(mave);
    OCMExpect([maveMock isSetupOK]).andReturn(NO);

    __block BOOL called = NO;
    // dismissal block nil triggers error
    [mave presentInvitePagePushWithBlock:^(UIViewController *inviteController) {
        called = YES;
    }
                               forwardBlock:nil
                               backBlock:nil
                           inviteContext:@"foocontext"];
    // does not call block to present since the invite controller will be null
    OCMVerifyAll(maveMock);
    XCTAssertFalse(called);
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