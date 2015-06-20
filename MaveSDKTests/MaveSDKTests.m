//
//  MaveSDKTests.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
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
#import "MAVEIDUtils.h"
#import "MAVEABUtils.h"
#import "MAVEABPermissionPromptHandler.h"

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
    XCTAssertNotNil(mave.referringDataBuilder);
    XCTAssertFalse(mave.debug);
    XCTAssertEqual(mave.debugInvitePageType, MAVEInvitePageTypeNone);
    XCTAssertEqual(mave.debugNumberOfRandomSuggestedInvites, 0);
    XCTAssertEqual(mave.debugSuggestedInvitesDelaySeconds, 0);
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
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.recordID = 0; p0.hashedRecordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1; p1.hashedRecordID = 1;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.recordID = 2; p2.hashedRecordID = 2;
    MAVEABPerson *p0dup = [[MAVEABPerson alloc] init]; p0dup.recordID = 0; p0dup.hashedRecordID = 0;
    MAVEABPerson *p2dup = [[MAVEABPerson alloc] init]; p2dup.recordID = 0; p2dup.hashedRecordID = 2;

    NSArray *contacts = @[p0, p1, p2];
    NSArray *suggestionsWrongInstances = @[p2dup, p0dup];
    NSArray *expectedSuggestions = @[p2, p0];
    for (MAVEABPerson *_p in expectedSuggestions) {
        XCTAssertFalse(_p.isSuggestedContact);
    }

    MAVESuggestedInvites *suggestedObject = [[MAVESuggestedInvites alloc] init];
    suggestedObject.suggestions = suggestionsWrongInstances;

    CGFloat delay = 1.234;
    id builderMock = OCMClassMock([MAVERemoteObjectBuilder class]);
    OCMExpect([builderMock createObjectSynchronousWithTimeout:delay]).andReturn(suggestedObject);
    [MaveSDK sharedInstance].suggestedInvitesBuilder = builderMock;

    NSArray *returnedSuggestions = [[MaveSDK sharedInstance] suggestedInvitesWithFullContactsList:contacts delay:delay];

    XCTAssertEqualObjects(returnedSuggestions, expectedSuggestions);
    OCMVerifyAll(builderMock);

    // Suggestions should also now be marked as isSuggestedInvite
    for (MAVEABPerson *_p in expectedSuggestions) {
        XCTAssertTrue(_p.isSuggestedContact);
    }
}

- (void)testGetReferringData {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"asd932k"];
    XCTAssertFalse([MaveSDK sharedInstance].debug);

    MAVEReferringData *referringDataObj = [[MAVEReferringData alloc] init];

    id referringBuilderMock = OCMClassMock([MAVERemoteObjectBuilder class]);
    [MaveSDK sharedInstance].referringDataBuilder = referringBuilderMock;
    OCMExpect([referringBuilderMock createObjectWithTimeout:4 completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        ((void (^)(id object))(obj))(referringDataObj);
        return YES;
    }]]);

    __block MAVEReferringData *returnedObject;
    [[MaveSDK sharedInstance] getReferringData:^(MAVEReferringData *referringData) {
        returnedObject = referringData;
    }];

    XCTAssertEqualObjects(returnedObject, referringDataObj);
    OCMVerifyAll(referringBuilderMock);
}

- (void)testDebugGetReferringData {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"asd932k"];
    MaveSDK *mave = [MaveSDK sharedInstance];

    mave.debug = YES;
    mave.debugFakeReferringData = [MaveSDK generateFakeReferringDataForTestingWithCustomData:@{@"foo": @"bar"}];
    __block BOOL ran = NO;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [mave getReferringData:^(MAVEReferringData *referringData) {
        XCTAssertNotNil(referringData.referringUser);
        XCTAssertNotNil(referringData.currentUser);
        XCTAssertEqualObjects([referringData.referringUser fullName], @"Danny Example");
        XCTAssertEqualObjects([referringData.referringUser.picture absoluteString],
                              @"http://mave.io/images/giraffe-face.jpg");
        XCTAssertEqualObjects(referringData.referringUser.email, @"danny@example.com");
        XCTAssertEqualObjects(referringData.referringUser.phone, @"+18085551111");
        // current user name is never known, except the name that the referring user had this person
        // saved under in his or her address book. Our api does not show that name to the current user.
        XCTAssertNil([referringData.currentUser fullName]);
        XCTAssertEqualObjects(referringData.currentUser.phone, @"+12125559999");
        XCTAssertEqualObjects(referringData.customData, @{@"foo": @"bar"});
        ran = YES;
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));
    XCTAssertTrue(ran);
}

- (void)testGetSuggestedInvites {
    id abUtilsMock = OCMClassMock([MAVEABUtils class]);
    OCMStub([abUtilsMock addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusAllowed);

    MaveSDK *mave = [MaveSDK sharedInstance];
    XCTAssertFalse(mave.debug);
    id maveMock = OCMPartialMock(mave);
    NSArray *fakeSuggestions = @[@2];

    NSArray *fakeAllContacts = @[@1, @1];
    id handlerMock = OCMClassMock([MAVEABPermissionPromptHandler class]);
    OCMExpect([handlerMock promptForContactsWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSArray *contacts) = obj;
        completionBlock(fakeAllContacts);
        return YES;
    }]]);

    OCMExpect([maveMock suggestedInvitesWithFullContactsList:fakeAllContacts delay:2.4f]).andReturn(fakeSuggestions);

    __block NSArray *results = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [mave getSuggestedInvites:^(NSArray *suggestedInvites) {
        results = suggestedInvites;
        dispatch_semaphore_signal(sema);
    } timeout:2.4f];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));

    XCTAssertEqualObjects(results, fakeSuggestions);
    OCMVerifyAll(maveMock);
    OCMVerifyAll(handlerMock);
}

- (void)testGetSuggestedInvitesWhenNoContactsPermission {
    id abUtilsMock = OCMClassMock([MAVEABUtils class]);
    OCMStub([abUtilsMock addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusUnprompted);

    MaveSDK *mave = [MaveSDK sharedInstance];
    __block NSArray *results;
    __block BOOL blockRan = NO;
    [mave getSuggestedInvites:^(NSArray *suggestedInvites) {
        results = suggestedInvites;
        blockRan = YES;
    } timeout:1.0];

    XCTAssertTrue(blockRan);
    XCTAssertNil(results);
}

- (void)testGetDebugSuggestedInvitesWithFullContactsList {
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.recordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.recordID = 2;
    NSArray *contacts = @[p0, p1, p2];

    MaveSDK *mave = [MaveSDK sharedInstance];
    mave.debug = YES;
    // delay is the min of this variable and the timeout delay passed to the method
    mave.debugSuggestedInvitesDelaySeconds = 0.01f;
    mave.debugNumberOfRandomSuggestedInvites = 3;
    NSArray *s0 = [mave suggestedInvitesWithFullContactsList:contacts delay:10];
    XCTAssertEqual([s0 count], 3);
    XCTAssertTrue([s0 containsObject:p0]);
    XCTAssertTrue([s0 containsObject:p1]);
    XCTAssertTrue([s0 containsObject:p2]);

    mave.debugSuggestedInvitesDelaySeconds = 30;
    mave.debugNumberOfRandomSuggestedInvites = 2;
    NSArray *s1 = [mave suggestedInvitesWithFullContactsList:contacts delay:0];
    XCTAssertEqual([s1 count], 2);

    // cant get more than the number of contacts
    mave.debugNumberOfRandomSuggestedInvites = 5;
    NSArray *s2 = [mave suggestedInvitesWithFullContactsList:contacts delay:0];
    XCTAssertEqual([s2 count], 3);

    // getting 0 works fine
    mave.debugNumberOfRandomSuggestedInvites = 0;
    NSArray *s3 = [mave suggestedInvitesWithFullContactsList:contacts delay:0];
    XCTAssertEqual([s3 count], 0);
}


- (void) testDefaultSMSText {
    MaveSDK *mave = [MaveSDK sharedInstance];

    // can be set in remote config
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
    remoteConfig.serverSMS = [[MAVERemoteConfigurationServerSMS alloc] init];
    remoteConfig.serverSMS.textTemplate = @"foo";
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
    remoteConfig.contactsInvitePage.explanationCopyTemplate = @"foo";
    id maveMock = OCMPartialMock(mave);
    OCMStub([maveMock remoteConfiguration]).andReturn(remoteConfig);

    // if set explicitly in display options, return that as explanation text
    mave.displayOptions.inviteExplanationCopy = @"bar";
    XCTAssertEqualObjects(mave.inviteExplanationCopy, @"bar");

    // if not set, return the value from remote config
    mave.displayOptions.inviteExplanationCopy = nil;
    XCTAssertEqualObjects(mave.inviteExplanationCopy, @"foo");
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

- (void)testUserDataGetsFromUserDefaultsIfNotSet {
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

- (void)testIsInitialLaunchYesWhenNoStoredAdid {
    // We use the presence of an app_device_id having been read from disk
    // to mean that the app has been launched before, if it's not on disk
    // then this is the first time the app has been launched
    [MAVEIDUtils clearStoredAppDeviceID];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertTrue([MaveSDK sharedInstance].isInitialAppLaunch);
}

- (void)testIsInitialLaunchNoOnSubsequentLaunches {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertNotNil([MaveSDK sharedInstance].appDeviceID);
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertFalse([MaveSDK sharedInstance].isInitialAppLaunch);
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

- (void)testTrackSignup {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
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


# pragma mark - Send SMS programatically Tests

- (void)testSendSMSInviteMessageProgramaticallySuccessWithOptions {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foobar123"];

    // setup the user to send sms from
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.userID = @"1"; user.firstName = @"Dan"; user.wrapInviteLink = YES;
    [[MaveSDK sharedInstance] identifyUser:user];

    // mock the underlying method
    NSString *message = @"hello this is an invite";
    NSArray *recipientPhones = @[@"8085551234", @"wontgetvalidatedclientsideanyway"];
    NSString *linkDestinationURL = @"http://example.com/signup";
    NSDictionary *customData = @{@"foo0": @"bar", @"foo1": [NSNull null], @"foo2": @13.5};
    NSString *context = @"blahcontext";
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock sendInvitesWithRecipientPhoneNumbers:recipientPhones
                                             recipientContactRecords:nil
                                                             message:message
                                                              userId:user.userID
                                            inviteLinkDestinationURL:linkDestinationURL
                                                      wrapInviteLink:YES
                                                          customData:customData
                                                     completionBlock:[OCMArg any]]);

    NSDictionary *additionalOptions = @{
        @"invite_context": context,
        @"link_destination_url": linkDestinationURL,
        @"custom_referring_data": customData,
        };
    __block NSError *returnedError = nil;
    [[MaveSDK sharedInstance] sendSMSInviteMessage:message
                                      toRecipients:recipientPhones
                                 additionalOptions:additionalOptions
                                        errorBlock:^(NSError *error) {
                                            returnedError = error;
                                        }];

    XCTAssertNil(returnedError);
    OCMVerifyAll(apiInterfaceMock);
    // should have set the global invite context before sending
    XCTAssertEqualObjects([MaveSDK sharedInstance].inviteContext, context);
}

- (void)testSendSMSInviteMessageProgramaticallySuccessWithNoOptions {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foobar123"];

    // setup the user to send sms from
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.userID = @"1"; user.firstName = @"Dan"; user.wrapInviteLink = NO;
    [[MaveSDK sharedInstance] identifyUser:user];

    // mock the underlying method
    NSString *message = @"hello this is an invite";
    NSArray *recipientPhones = @[@"8085551234", @"wontgetvalidatedclientsideanyway"];
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock sendInvitesWithRecipientPhoneNumbers:recipientPhones
                                             recipientContactRecords:nil
                                                             message:message
                                                              userId:user.userID
                                            inviteLinkDestinationURL:nil
                                                      wrapInviteLink:NO
                                                          customData:nil
                                                     completionBlock:[OCMArg any]]);

    __block NSError *returnedError = nil;
    [[MaveSDK sharedInstance] sendSMSInviteMessage:message
                                      toRecipients:recipientPhones
                                 additionalOptions:nil
                                        errorBlock:^(NSError *error) {
                                            returnedError = error;
                                        }];

    XCTAssertNil(returnedError);
    OCMVerifyAll(apiInterfaceMock);
    // should have set the global invite context before sending
    XCTAssertEqualObjects([MaveSDK sharedInstance].inviteContext, @"programatic invite");
}

- (void)testSendSMSInviteMessageProgramaticallyFailsWithBadUserData {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foobar123"];

    // setup the user to send sms from
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.userID = @"1"; // user has no name
    [[MaveSDK sharedInstance] identifyUser:user];

    // mock the underlying method
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject] sendInvitesWithRecipientPhoneNumbers:[OCMArg any]
                                            recipientContactRecords:[OCMArg any]
                                                            message:[OCMArg any]
                                                             userId:user.userID
                                           inviteLinkDestinationURL:nil
                                                     wrapInviteLink:NO
                                                         customData:nil
                                                    completionBlock:[OCMArg any]];

    __block NSError *returnedError = nil;
    [[MaveSDK sharedInstance] sendSMSInviteMessage:@"2"
                                      toRecipients:@[@"vasd"]
                                 additionalOptions:nil
                                        errorBlock:^(NSError *error) {
                                            returnedError = error;
                                        }];

    XCTAssertNotNil(returnedError);
    XCTAssertEqualObjects([returnedError.userInfo objectForKey:@"message"], @"user firstName set to nil");
    OCMVerifyAll(apiInterfaceMock);
    // should have set the global invite context before sending
    XCTAssertNil([MaveSDK sharedInstance].inviteContext);
}

- (void)testSendSMSInviteMessageProgramaticallyFailsIfNetworkRequestFails {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foobar123"];

    // setup the user to send sms from
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.userID = @"1"; user.firstName = @"Dan"; user.wrapInviteLink = YES;
    [[MaveSDK sharedInstance] identifyUser:user];

    // mock the underlying method
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock sendInvitesWithRecipientPhoneNumbers:[OCMArg any]
                                             recipientContactRecords:[OCMArg any]
                                                             message:[OCMArg any]
                                                              userId:user.userID
                                            inviteLinkDestinationURL:nil
                                                      wrapInviteLink:YES
                                                          customData:nil
                                                     completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        MAVEHTTPCompletionBlock completionBlock = obj;
        NSError *requestError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN code:400 userInfo:@{}];
        completionBlock(requestError, nil);
        return YES;
    }]]);

    __block NSError *returnedError = nil;
    [[MaveSDK sharedInstance] sendSMSInviteMessage:@"2"
                                      toRecipients:@[@"vasd"]
                                 additionalOptions:nil
                                        errorBlock:^(NSError *error) {
                                            returnedError = error;
                                        }];

    XCTAssertNotNil(returnedError);
    XCTAssertEqualObjects([returnedError.userInfo objectForKey:@"message"],
                          @"Error making request to send SMS invites");
    OCMVerifyAll(apiInterfaceMock);
    // should have set the global invite context before sending
    XCTAssertEqualObjects([MaveSDK sharedInstance].inviteContext, @"programatic invite");
}

- (void)testSendSMSInviteMessageProgramaticallyWithNilErrorBlockIsOk {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foobar123"];
    [MaveSDK sharedInstance].userData = nil;
    // no user data is set up

    // mock the underlying method
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject] sendInvitesWithRecipientPhoneNumbers:[OCMArg any]
                                            recipientContactRecords:[OCMArg any]
                                                            message:[OCMArg any]
                                                             userId:[OCMArg any]
                                           inviteLinkDestinationURL:[OCMArg any]
                                                     wrapInviteLink:NO
                                                         customData:[OCMArg any]
                                                    completionBlock:[OCMArg any]];

    [[MaveSDK sharedInstance] sendSMSInviteMessage:@"2"
                                      toRecipients:@[@"vasd"]
                                 additionalOptions:nil
                                        errorBlock:nil];

    OCMVerifyAll(apiInterfaceMock);
    // should have set the global invite context before sending
    XCTAssertNil([MaveSDK sharedInstance].inviteContext);
}

- (void)testSendSMSInviteMessageProgramaticallyFailsIfCustomReferringDataNotIsValidJSONObject {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foobar123"];
    // setup the user to send sms from
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.userID = @"1"; user.firstName = @"Dan"; user.wrapInviteLink = YES;
    [[MaveSDK sharedInstance] identifyUser:user];

    // mock the underlying method
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject] sendInvitesWithRecipientPhoneNumbers:[OCMArg any]
                                            recipientContactRecords:[OCMArg any]
                                                            message:[OCMArg any]
                                                             userId:[OCMArg any]
                                           inviteLinkDestinationURL:[OCMArg any]
                                                     wrapInviteLink:YES
                                                         customData:[OCMArg any]
                                                    completionBlock:[OCMArg any]];

    NSDictionary *badCustomReferringData = @{@"foo": [[NSObject alloc] init]};
    NSDictionary *options = @{@"custom_referring_data": badCustomReferringData};
    __block NSError *returnedError;
    [[MaveSDK sharedInstance] sendSMSInviteMessage:@"2"
                                      toRecipients:@[@"vasd"]
                                 additionalOptions:options
                                        errorBlock:^(NSError *error) {
                                            returnedError = error;
                                        }];

    XCTAssertNotNil(returnedError);
    XCTAssertEqualObjects(returnedError.domain, MAVE_VALIDATION_ERROR_DOMAIN);
    XCTAssertEqualObjects([returnedError.userInfo objectForKey:@"message"],
                          @"custom_referring_data parameter can't be serialized as JSON");
    OCMVerifyAll(apiInterfaceMock);
}

@end
