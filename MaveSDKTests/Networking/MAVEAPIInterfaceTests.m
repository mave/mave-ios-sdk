//
//  MAVEHTTPInterfaceTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/2/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVEAPIInterface.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVECompressionUtils.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEAPIInterfaceTests : XCTestCase

@property MAVEAPIInterface *testAPIInterface;

@end

@implementation MAVEAPIInterfaceTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"12345"];
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1"
                                                    firstName:@"foo"
                                                     lastName:@"bar"
                                                        email:nil
                                                        phone:nil];
    [[MaveSDK sharedInstance] identifyUser:user];
    self.testAPIInterface = [[MAVEAPIInterface alloc] init];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitAndCurrentUserProperties {
    XCTAssertEqualObjects(MAVEAPIBaseURL, @"test-api-mave-io/");
    XCTAssertEqualObjects(self.testAPIInterface.httpStack.baseURL, @"test-api-mave-io/v1.0");
    XCTAssertEqualObjects(self.testAPIInterface.applicationID, [MaveSDK sharedInstance].appId);
    XCTAssertEqualObjects(self.testAPIInterface.applicationDeviceID, [MaveSDK sharedInstance].appDeviceID);
    XCTAssertEqualObjects(self.testAPIInterface.userData, [MaveSDK sharedInstance].userData);
}

///
/// Specific tracking events
///
- (void)testTrackAppOpen {
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackAppLaunch additionalParams:nil completionBlock:nil]);
    [self.testAPIInterface trackAppOpen];
    OCMVerifyAll(mock);
}

- (void)testTrackAppOpenFetchingReferringDataWithPromise {
    NSDictionary *expectedParams = @{@"return_referring_data": @YES};
    NSDictionary *fakeReferringData = @{@"foo": @"bar"};
    NSDictionary *fakeResponse = @{@"referring_data": fakeReferringData};

    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackAppLaunch additionalParams:expectedParams completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        MAVEHTTPCompletionBlock completionBlock = obj;
        completionBlock(nil, fakeResponse);
        return YES;
    }]]);

    id promiseMock = OCMClassMock([MAVEPromise class]);
    OCMExpect([promiseMock fulfillPromise:(NSValue *)fakeReferringData]);

    [self.testAPIInterface trackAppOpenFetchingReferringDataWithPromise:promiseMock];

    OCMVerifyAll(mock);
    OCMVerifyAll(promiseMock);
}


- (void)testTrackSignup {
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackSignup additionalParams:nil completionBlock:nil]);
    [self.testAPIInterface trackSignup];
    OCMVerifyAll(mock);
}

- (void)testTrackInvitePageOpen {
    // With a value
    NSString *type = @"blahblahtype";
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                                  additionalParams:@{MAVEAPIParamInvitePageType: type}
                                   completionBlock:nil]);
    [self.testAPIInterface trackInvitePageOpenForPageType:type];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    // nil and empty string get set as unknown
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                                  additionalParams:@{MAVEAPIParamInvitePageType: @"unknown"}
                                   completionBlock:nil]);
    [self.testAPIInterface trackInvitePageOpenForPageType:nil];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                                  additionalParams:@{MAVEAPIParamInvitePageType: @"unknown"}
                                   completionBlock:nil]);
    [self.testAPIInterface trackInvitePageOpenForPageType:@""];
    OCMVerifyAll(mock);
    [mock stopMocking];
}

- (void)testTrackInvitePageSelectedContact {
    NSString *listType = @"fooblahtype";
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageSelectedContact
                                  additionalParams:@{MAVEAPIParamContactSelectedFromList: listType}
                                   completionBlock:nil]);
    [self.testAPIInterface trackInvitePageSelectedContactFromList:listType];
    OCMVerifyAll(mock);
    [mock stopMocking];

    // if list type is empty it'll be set to unknown
    listType = nil;
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageSelectedContact
                                  additionalParams:@{MAVEAPIParamContactSelectedFromList: @"unknown"}
                                   completionBlock:nil]);
    [self.testAPIInterface trackInvitePageSelectedContactFromList:listType];
    OCMVerifyAll(mock);
    [mock stopMocking];
}

- (void)testTrackShareActionClick {
    // With a value
    NSString *type = @"foo";
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackShareActionClick additionalParams:@{@"medium": type} completionBlock:nil]);
    [self.testAPIInterface trackShareActionClickWithShareType:type];
    OCMVerifyAll(mock);
    [mock stopMocking];

     // if type is nil it becomes "unkown"
    type = nil;
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackShareActionClick additionalParams:@{@"medium": @"unknown"} completionBlock:nil]);
    [self.testAPIInterface trackShareActionClickWithShareType:type];
    OCMVerifyAll(mock);
    [mock stopMocking];
}

- (void)testTracKShare {
    // With a value
    NSString *type = @"foo";
    NSString *token = @"bar";
    NSString *audience = @"all";
    id mock = OCMPartialMock(self.testAPIInterface);
    NSDictionary *params = @{@"medium": type, @"share_token": token, @"audience": audience};
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackShare additionalParams:params completionBlock:nil]);
    [self.testAPIInterface trackShareWithShareType:type shareToken:token audience:audience];
    OCMVerifyAll(mock);
    [mock stopMocking];

    // if type is nil it becomes "unkown" and nil for token
    type = nil; token = nil; audience = nil;
    mock = OCMPartialMock(self.testAPIInterface);
    params = @{@"medium": @"unknown", @"share_token": @"", @"audience": @"unknown"};
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackShare additionalParams:params completionBlock:nil]);
    [self.testAPIInterface trackShareWithShareType:type shareToken:token audience:audience];
    OCMVerifyAll(mock);
    [mock stopMocking];
}

///
/// Other specific requests
///
- (void)testIdentifyUserRequest {
    id mock = OCMPartialMock(self.testAPIInterface);
    MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Dan" lastName:@"Foo" email:@"foo@bar.com" phone:@"18085551234"];
    OCMStub([mock userData]).andReturn(userData);
    NSDictionary *expectedParams = @{@"user_id": userData.userID,
                                     @"first_name": userData.firstName,
                                     @"last_name": userData.lastName,
                                     @"email": userData.email,
                                     @"phone": userData.phone};
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:@"/users"
                                            methodName:@"PUT"
                                                params:expectedParams
                                      gzipCompressBody:NO
                                       completionBlock:nil]);
    [self.testAPIInterface identifyUser];
    OCMVerifyAll(mock);
}

- (void)testIdentifyUserWithMinimalParams {
    // user id is the only property of the user data required to be non-nil to make the identify user request
    id mocked = OCMPartialMock(self.testAPIInterface);
    [MaveSDK sharedInstance].userData = [[MAVEUserData alloc] init];
    // user id is missing so request will fail but it will still get attempted
    NSDictionary *expectedParams = @{};
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/users"
                                             methodName:@"PUT"
                                                 params:expectedParams
                                        gzipCompressBody:NO
                                        completionBlock:nil]);
    [self.testAPIInterface identifyUser];
    OCMVerifyAll(mocked);
}

- (void)testSendInvites {
    id mocked = OCMPartialMock(self.testAPIInterface);
    NSArray *recipientPhones = @[@"18085551234", @"18085555678"];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1; p1.firstName = @"Foo";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.recordID = 2; p2.firstName = @"Bar";
    NSArray *recipientContacts = @[p1, p2];
    NSArray *recipientContactsSerializable = @[[p1 toJSONDictionary], [p2 toJSONDictionary]];
    NSString *smsCopy = @"This is as test";
    NSString *userId = @"some-user-id";
    NSString *linkDestination = @"http://example.com/foo?code=hello";
    NSDictionary *customData = @{@"foo0": @"bar"};
    NSDictionary *expectedParams = @{@"recipient_phone_numbers": recipientPhones,
                                     @"recipient_contact_records": recipientContactsSerializable,
                                     @"sms_copy": smsCopy,
                                     @"sender_user_id": userId,
                                     @"link_destination": linkDestination,
                                     @"wrap_invite_link": @NO,
                                     @"custom_data": customData,
                                     };
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/invites/sms"
                                             methodName:@"POST"
                                                 params:expectedParams
                                        gzipCompressBody:NO
                                        completionBlock:nil]);

    [self.testAPIInterface sendInvitesWithRecipientPhoneNumbers:recipientPhones
                                        recipientContactRecords:recipientContacts
                                                        message:smsCopy
                                                         userId:userId
                                       inviteLinkDestinationURL:linkDestination
                                                 wrapInviteLink:NO
                                                     customData:customData
                                                completionBlock:nil];
    OCMVerifyAll(mocked);
}

- (void)testSendInvitesLinkDestinationEmptyFields {
    id mocked = OCMPartialMock(self.testAPIInterface);
    NSDictionary *expectedParams = @{@"recipient_phone_numbers": @[],
                                     @"sms_copy": @"",
                                     @"sender_user_id": @"",
                                     @"wrap_invite_link": @YES,
                                     };
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/invites/sms"
                                             methodName:@"POST"
                                                 params:expectedParams
                                        gzipCompressBody:NO
                                        completionBlock:nil]);

    [self.testAPIInterface sendInvitesWithRecipientPhoneNumbers:@[]
                                        recipientContactRecords:nil
                                                        message:@""
                                                         userId:@""
                                       inviteLinkDestinationURL:nil
                                                 wrapInviteLink:YES
                                                     customData:nil
                                                completionBlock:nil];
    OCMVerifyAll(mocked);
}

- (void)testSendContactsMerkleTree {
    id mocked = OCMPartialMock(self.testAPIInterface);
    id merkleTreeMock = OCMClassMock([MAVEMerkleTree class]);
    NSDictionary *fakeJSON = @{@"foobarjson": @1};
    NSUInteger fakeHeight = 25;
    OCMStub([merkleTreeMock serializable]).andReturn(fakeJSON);
    OCMStub([merkleTreeMock height]).andReturn(fakeHeight);
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/me/contacts/merkle_tree/full"
                                              methodName:@"PUT"
                                                  params:fakeJSON
                                        gzipCompressBody:YES
                                         completionBlock:nil]);
    [self.testAPIInterface sendContactsMerkleTree:merkleTreeMock];

    OCMVerifyAll(mocked);
    OCMVerifyAll(merkleTreeMock);
}

- (void)testSendContactsChangesetWithoutReturningClosest {
    id mocked = OCMPartialMock(self.testAPIInterface);
    NSArray *fakeChangeset = @[@"some changset"];
    NSDictionary *expectedJSON = @{@"changeset_list": fakeChangeset,
                                   @"is_full_initial_sync": @YES,
                                   @"own_merkle_tree_root": @"barfoo",
                                   @"return_closest_contacts": @NO};

    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/me/contacts/sync_changesets"
                                              methodName:@"POST"
                                                  params:expectedJSON
                                        gzipCompressBody:YES
                                         completionBlock:[OCMArg any]]);

    [self.testAPIInterface sendContactsChangeset:fakeChangeset
                               isFullInitialSync:YES
                               ownMerkleTreeRoot:@"barfoo"
                           returnClosestContacts:NO
                                 completionBlock:nil];
    OCMVerifyAll(mocked);
}

- (void)testSendContactsChangesetReturningClosestHashedRecordIDs {
    // Set up expected request body
    id mocked = OCMPartialMock(self.testAPIInterface);
    NSArray *fakeChangeset = @[@"some changset"];
    NSDictionary *expectedJSON = @{@"changeset_list": fakeChangeset,
                                   @"is_full_initial_sync": @NO,
                                   @"own_merkle_tree_root": @"barfoo2",
                                   @"return_closest_contacts": @YES};

    // set up expected response behavior
    NSArray *fakeClosestHashedRecordIDs = @[@"hrid1", @"hrid2"];
    __block NSArray *returnedClosestHashedRecordIDs;
    void (^returnBlock)(NSArray * closestContacts) = ^void(NSArray * closestContacts) {
        returnedClosestHashedRecordIDs = closestContacts;
    };
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/me/contacts/sync_changesets"
                                              methodName:@"POST"
                                                  params:expectedJSON
                                        gzipCompressBody:YES
                                         completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        MAVEHTTPCompletionBlock completionBlock = obj;
        NSDictionary *returnVal = @{@"closest_contacts": fakeClosestHashedRecordIDs};
        completionBlock(nil, returnVal);
        return YES;
    }]]);

    // Run code under test
    [self.testAPIInterface sendContactsChangeset:fakeChangeset
                               isFullInitialSync:NO
                               ownMerkleTreeRoot:@"barfoo2"
                           returnClosestContacts:YES
                                 completionBlock:returnBlock];
    OCMVerifyAll(mocked);
    XCTAssertEqualObjects(returnedClosestHashedRecordIDs, fakeClosestHashedRecordIDs);
}

- (void)testGetReferringData {
    id mocked = OCMPartialMock(self.testAPIInterface);
    MAVEHTTPCompletionBlock expectedBlock = ^void(NSError *error, NSDictionary *responseData) {};
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/referring_data"
                                              methodName:@"GET"
                                                  params:nil
                                        gzipCompressBody:NO
                                         completionBlock:expectedBlock]);
    [self.testAPIInterface getReferringData:expectedBlock];
    OCMVerifyAll(mocked);
}


- (void)testGetClosestContactsHashedRecordIDs {
    NSArray *closestContacts = @[@"foo", @"bar"];

    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:@"/me/contacts/closest"
                                            methodName:@"GET"
                                                params:nil
                                      gzipCompressBody:NO
                                       completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        // Call the completion block with data, and then later check the data was returned
        NSDictionary *fakeResponseData = @{@"closest_contacts": closestContacts};
        ((void(^)(NSError *error, NSDictionary *responseData)) obj)(nil, fakeResponseData);
        return YES;
    }]]);

    __block NSArray *closestContactsReturned;
    [self.testAPIInterface getClosestContactsHashedRecordIDs:^(NSArray *_closestContacts) {
        closestContactsReturned = _closestContacts;
    }];

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(closestContactsReturned, closestContacts);
}

- (void)testGetRemoteConfiguration {
    MAVEHTTPCompletionBlock myBlock = ^(NSError *error, NSDictionary *data){};

    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:@"/remote_configuration/ios"
                                            methodName:@"GET"
                                                params:nil
                                      gzipCompressBody:NO
                                       completionBlock:myBlock];
    [self.testAPIInterface getRemoteConfigurationWithCompletionBlock:myBlock]);
    OCMVerifyAll(mock);
}

- (void)testGetNewShareToken {
    MAVEHTTPCompletionBlock myBlock = ^(NSError *error, NSDictionary *data){};

    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:@"/remote_configuration/universal/share_token"
                                            methodName:@"GET"
                                                params:nil
                                      gzipCompressBody:NO
                                       completionBlock:myBlock];
    [self.testAPIInterface getNewShareTokenWithCompletionBlock:myBlock]);
    OCMVerifyAll(mock);
}

- (void)testGetRemoteContactsMerkleTreeRoot {
    MAVEHTTPCompletionBlock myBlock = ^(NSError *error, NSDictionary *data){};

    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:@"/me/contacts/merkle_tree/root"
                                            methodName:@"GET"
                                                params:nil
                                      gzipCompressBody:NO
                                       completionBlock:myBlock]);
    [self.testAPIInterface getRemoteContactsMerkleTreeRootWithCompletionBlock:myBlock];
    OCMVerifyAll(mock);
}

- (void)testGetRemoteContactsFullMerkleTree {
    MAVEHTTPCompletionBlock myBlock = ^(NSError *error, NSDictionary *data){};

    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:@"/me/contacts/merkle_tree/full"
                                            methodName:@"GET"
                                                params:nil
                                      gzipCompressBody:NO
                                       completionBlock:myBlock]);
    [self.testAPIInterface getRemoteContactsFullMerkleTreeWithCompletionBlock:myBlock];
    OCMVerifyAll(mock);
}


///
/// Request building logic
///
- (void)testAddCustomUserHeadersToRequest {
    // invite context is stored on singleton object
    [MaveSDK sharedInstance].inviteContext = @"foobartestcontext";

    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    XCTAssertEqual([req.allHTTPHeaderFields count], 0);
    
    [self.testAPIInterface addCustomUserHeadersToRequest:req];
    NSDictionary *headers = req.allHTTPHeaderFields;
    XCTAssertEqual([headers count], 6);
    XCTAssertEqualObjects([headers objectForKey:@"X-Application-Id"],
                          [MaveSDK sharedInstance].appId);
    XCTAssertEqualObjects([headers objectForKey:@"X-App-Device-Id"],
                          [MaveSDK sharedInstance].appDeviceID);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSString *expectedDimensions = [NSString stringWithFormat:@"%ldx%ld",
                                    (long)screenSize.width, (long)screenSize.height];
    NSString *expectedUserAgent = [MAVEClientPropertyUtils userAgentDeviceString];
    NSString *expectedClientProperties = [MAVEClientPropertyUtils encodedAutomaticClientProperties];
    NSString *expectedContextProperties = [MAVEClientPropertyUtils encodedContextProperties];
    XCTAssertEqualObjects([headers objectForKey:@"X-Device-Screen-Dimensions"],
                          expectedDimensions);
    XCTAssertEqualObjects([headers objectForKey:@"User-Agent"], expectedUserAgent);
    XCTAssertEqualObjects([headers objectForKey:@"X-Client-Properties"], expectedClientProperties);
    XCTAssertEqualObjects([headers objectForKey:@"X-Context-Properties"], expectedContextProperties);
}

- (void)testSendIdentifiedJSONRequestSuccess {
    id httpStackMock = OCMPartialMock(self.testAPIInterface.httpStack);
    id httpInterfaceMock = OCMPartialMock(self.testAPIInterface);
    
    NSString *route = @"/blah/boo";
    NSString *methodName = @"DANNY";
    NSDictionary *params = @{@"foo": @3};
    BOOL useGzip = NO; // no gzip for this one
    MAVEHTTPCompletionBlock completionBlock = ^void(NSError *error, NSDictionary *responseData) {};
    
    OCMExpect([httpStackMock prepareJSONRequestWithRoute:route
                                              methodName:methodName
                                                  params:params
                                         contentEncoding:MAVEHTTPRequestContentEncodingDefault
                                        preparationError:[OCMArg setTo:nil]]);
    OCMExpect([httpStackMock sendPreparedRequest:[OCMArg any] completionBlock:completionBlock]);
    OCMExpect([httpInterfaceMock addCustomUserHeadersToRequest:[OCMArg any]]);
    
    [self.testAPIInterface sendIdentifiedJSONRequestWithRoute:route
                                                    methodName:methodName
                                                        params:params
                                             gzipCompressBody:useGzip
                                               completionBlock:completionBlock];
    OCMVerifyAll(httpStackMock);
    OCMVerifyAll(httpInterfaceMock);
}

- (void)testSendIdentifiedJSONRequestError {
    id httpStackMock = OCMPartialMock(self.testAPIInterface.httpStack);
    
    NSString *route = @"/blah/boo";
    NSString *methodName = @"DANNY";
    NSDictionary *params = @{@"foo": @3};
    BOOL useGzip = YES; // use gzip for this one so we're testing both cases
    NSError *expectedError = [[NSError alloc] initWithDomain:@"TEST.foo" code:1 userInfo:@{}];
    
    OCMExpect([httpStackMock prepareJSONRequestWithRoute:route
                                              methodName:methodName
                                                  params:params
                                         contentEncoding:MAVEHTTPRequestContentEncodingGzip
                                        preparationError:[OCMArg setTo:expectedError]]);

    // If error arrises, our block should be called with the error
    __block BOOL called;
    __block NSError *returnedError;
    __block NSDictionary *returnedData;
    [self.testAPIInterface sendIdentifiedJSONRequestWithRoute:route
                                                    methodName:methodName
                                                        params:params
                                             gzipCompressBody:useGzip
                                               completionBlock:^void(NSError *error, NSDictionary *responseData) {
                                                   called = YES;
                                                   returnedError = error;
                                                   returnedData = responseData;
                                               }];
    OCMVerifyAll(httpStackMock);
    XCTAssertTrue(called);
    XCTAssertEqualObjects(returnedError, expectedError);
    XCTAssertNil(returnedData);
}

- (void)testTrackGenericUserEvent {
    NSString *fakeRoute = @"/foo/bar/afsdfasdf";
    NSDictionary *additionalParams = @{@"blah": @"ok"};
    NSDictionary *expectedParams = @{@"user_id": [MaveSDK sharedInstance].userData.userID,
                                     @"blah": @"ok"};
    
    // When user data is set, combine user_id and expected params
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:fakeRoute
                                            methodName:@"POST"
                                                params:expectedParams
                                      gzipCompressBody:NO
                                       completionBlock:nil]);
    [self.testAPIInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:additionalParams completionBlock:nil];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    // When no user data set, the user id not added to the params
    [MaveSDK sharedInstance].userData = nil;
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:fakeRoute
                                            methodName:@"POST"
                                                params:additionalParams
                                      gzipCompressBody:NO
                                       completionBlock:nil]);
    [self.testAPIInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:additionalParams completionBlock:nil];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    // When additional params are nil, params are empty
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:fakeRoute
                                            methodName:@"POST"
                                                params:@{}
                                      gzipCompressBody:NO
                                       completionBlock:nil]);
    [self.testAPIInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:nil completionBlock:nil];
    OCMVerifyAll(mock);
    [mock stopMocking];

    // when completion block is passed in, it gets passed through
    MAVEHTTPCompletionBlock completionBlock = ^void(NSError *error, NSDictionary *responseData) {};
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:fakeRoute
                                            methodName:@"POST"
                                                params:@{}
                                      gzipCompressBody:NO
                                       completionBlock:completionBlock]);
    [self.testAPIInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:nil completionBlock:completionBlock];
    OCMVerifyAll(mock);
}

@end