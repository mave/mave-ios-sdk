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
#import "MAVEBaseTestCase.h"
#import "MaveSDK.h"
#import "MaveSDK_Internal.h"
#import "MAVEInvitePageChooser.h"
#import "MAVEUserData.h"
#import "MAVEConstants.h"
#import "MAVEAPIInterface.h"
#import "MAVESuggestedInvites.h"
#import "MAVEIDUtils.h"

@interface MAVEABSyncManager(Testing)
+ (NSInteger)valueOfSyncContactsOnceToken;
+ (void)resetSyncContactsOnceTokenForTesting;
@end

@interface MaveSDKTests : MAVEBaseTestCase

@end

@implementation MaveSDKTests

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

    [self resetTestState];
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

    MAVESuggestedInvites *suggestedObject = [[MAVESuggestedInvites alloc] init];
    suggestedObject.suggestions = suggestionsWrongInstances;

    CGFloat delay = 1.234;
    id builderMock = OCMClassMock([MAVERemoteObjectBuilder class]);
    OCMExpect([builderMock createObjectSynchronousWithTimeout:delay]).andReturn(suggestedObject);
    [MaveSDK sharedInstance].suggestedInvitesBuilder = builderMock;

    NSArray *returnedSuggestions = [[MaveSDK sharedInstance] suggestedInvitesWithFullContactsList:contacts delay:delay];

    XCTAssertEqualObjects(returnedSuggestions, expectedSuggestions);
    OCMVerifyAll(builderMock);
}

- (void)testGetReferringData {
    [self resetTestState];

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
