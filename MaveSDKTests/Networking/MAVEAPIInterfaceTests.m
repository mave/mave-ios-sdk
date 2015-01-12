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
#import "MAVEAPIInterface.h"
#import "MAVEClientPropertyUtils.h"

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
    XCTAssertEqualObjects(self.testAPIInterface.httpStack.baseURL, @"http://devapi.mave.io/v1.0");
    XCTAssertEqualObjects(self.testAPIInterface.applicationID, [MaveSDK sharedInstance].appId);
    XCTAssertEqualObjects(self.testAPIInterface.applicationDeviceID, [MaveSDK sharedInstance].appDeviceID);
    XCTAssertEqualObjects(self.testAPIInterface.userData, [MaveSDK sharedInstance].userData);
}

///
/// Specific tracking events
///
- (void)testTrackAppOpen {
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackAppLaunch additionalParams:nil]);
    [self.testAPIInterface trackAppOpen];
    OCMVerifyAll(mock);
}

- (void)testTrackSignup {
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackSignup additionalParams:nil]);
    [self.testAPIInterface trackSignup];
    OCMVerifyAll(mock);
}

- (void)testTrackInvitePageOpen {
    // With a value
    NSString *type = @"blahblahtype";
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                                  additionalParams:@{MAVEAPIParamInvitePageType: type}]);
    [self.testAPIInterface trackInvitePageOpenForPageType:type];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    // nil and empty string get set as unknown
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                                  additionalParams:@{MAVEAPIParamInvitePageType: @"unknown"}]);
    [self.testAPIInterface trackInvitePageOpenForPageType:nil];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                                  additionalParams:@{MAVEAPIParamInvitePageType: @"unknown"}]);
    [self.testAPIInterface trackInvitePageOpenForPageType:@""];
    OCMVerifyAll(mock);
    [mock stopMocking];
}

- (void)testTrackShareActionClick {
    // With a value
    NSString *type = @"foo";
    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackShareActionClick additionalParams:@{@"medium": type}]);
    [self.testAPIInterface trackShareActionClickWithShareType:type];
    OCMVerifyAll(mock);
    [mock stopMocking];

     // if type is nil it becomes "unkown"
    type = nil;
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackShareActionClick additionalParams:@{@"medium": @"unknown"}]);
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
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackShare additionalParams:params]);
    [self.testAPIInterface trackShareWithShareType:type shareToken:token audience:audience];
    OCMVerifyAll(mock);
    [mock stopMocking];

    // if type is nil it becomes "unkown" and nil for token
    type = nil; token = nil; audience = nil;
    mock = OCMPartialMock(self.testAPIInterface);
    params = @{@"medium": @"unknown", @"share_token": @"", @"audience": @"unknown"};
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackShare additionalParams:params]);
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
                                        completionBlock:nil]);
    [self.testAPIInterface identifyUser];
    OCMVerifyAll(mocked);
}

- (void)testSendInvites {
    id mocked = OCMPartialMock(self.testAPIInterface);
    NSArray *recipients = @[@"18085551234", @"18085555678"];
    NSString *smsCopy = @"This is as test";
    NSString *userId = @"some-user-id";
    NSString *linkDestination = @"http://example.com/foo?code=hello";
    NSDictionary *expectedParams = @{@"recipients": recipients,
                                     @"sms_copy": smsCopy,
                                     @"sender_user_id": userId,
                                     @"link_destination": linkDestination,
                                     };
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/invites/sms"
                                             methodName:@"POST"
                                                 params:expectedParams
                                        completionBlock:nil]);
    [self.testAPIInterface sendInvitesWithPersons:recipients
                                           message:smsCopy
                                            userId:userId
                          inviteLinkDestinationURL:linkDestination
                                   completionBlock:nil];
    OCMVerifyAll(mocked);
}

- (void)testSendInvitesLinkDestinationOmittedIfEmpty {
    id mocked = OCMPartialMock(self.testAPIInterface);
    NSString *linkDestination = nil;
    NSDictionary *expectedParams = @{@"recipients": @[],
                                     @"sms_copy": @"",
                                     @"sender_user_id": @"",
                                     };
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/invites/sms"
                                             methodName:@"POST"
                                                 params:expectedParams
                                        completionBlock:nil]);
    [self.testAPIInterface sendInvitesWithPersons:@[]
                                           message:@""
                                            userId:@""
                          inviteLinkDestinationURL:linkDestination
                                   completionBlock:nil];
    OCMVerifyAll(mocked);
}

- (void)testGetReferringUser {
    id mocked = OCMPartialMock(self.testAPIInterface);
    NSDictionary *fakeResponseData = @{@"user_id": @"1", @"first_name": @"dan"};
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/referring_user"
                                              methodName:@"GET"
                                                  params:nil
                                         completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        // Call the completion block with data, and then later check that the userData
        // object got populated correctly from it
        ((void(^)(NSError *error, NSDictionary *responseData)) obj)(nil, fakeResponseData);
        return YES;
    }]]);
    __block MAVEUserData *userData;
    [self.testAPIInterface getReferringUser:^(MAVEUserData *_userData) {
        userData = _userData;
    }];
    OCMVerifyAll(mocked);
    XCTAssertEqualObjects(userData.userID, @"1");
    XCTAssertEqualObjects(userData.firstName, @"dan");
}

- (void)testGetReferringUserNull {
    // Same as above test, but this time the data returned from the server is nil
    id mocked = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/referring_user"
                                              methodName:@"GET"
                                                  params:nil
                                         completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSDictionary *fakeResponseData = nil;
        ((void(^)(NSError *error, NSDictionary *responseData)) obj)(nil, fakeResponseData);
        return YES;
    }]]);
    __block MAVEUserData *userData;
    [self.testAPIInterface getReferringUser:^(MAVEUserData *_userData) {
        userData = _userData;
    }];
    [mocked verify];
    
    XCTAssertNil(userData);
}

- (void)testGetRemoteConfiguration {
    MAVEHTTPCompletionBlock myBlock = ^(NSError *error, NSDictionary *data){};

    id mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:@"/remote_configuration/ios"
                                            methodName:@"GET"
                                                params:nil
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
                                       completionBlock:myBlock];
    [self.testAPIInterface getNewShareTokenWithCompletionBlock:myBlock]);
    OCMVerifyAll(mock);
}


///
/// Request building logic
///
- (void)testAddCustomUserHeadersToRequest {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    XCTAssertEqual([req.allHTTPHeaderFields count], 0);
    
    [self.testAPIInterface addCustomUserHeadersToRequest:req];
    NSDictionary *headers = req.allHTTPHeaderFields;
    XCTAssertEqual([headers count], 5);
    XCTAssertEqualObjects([headers objectForKey:@"X-Application-Id"],
                          [MaveSDK sharedInstance].appId);
    XCTAssertEqualObjects([headers objectForKey:@"X-App-Device-Id"],
                          [MaveSDK sharedInstance].appDeviceID);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSString *expectedDimensions = [NSString stringWithFormat:@"%ldx%ld",
                                    (long)screenSize.width, (long)screenSize.height];
    NSString *expectedUserAgent = [MAVEClientPropertyUtils userAgentDeviceString];
    NSString *expectedClientProperties = [MAVEClientPropertyUtils encodedAutomaticClientProperties];
    XCTAssertEqualObjects([headers objectForKey:@"X-Device-Screen-Dimensions"],
                          expectedDimensions);
    XCTAssertEqualObjects([headers objectForKey:@"User-Agent"], expectedUserAgent);
    XCTAssertEqualObjects([headers objectForKey:@"X-Client-Properties"], expectedClientProperties);
}

- (void)testSendIdentifiedJSONRequestSuccess {
    id httpStackMock = OCMPartialMock(self.testAPIInterface.httpStack);
    id httpInterfaceMock = OCMPartialMock(self.testAPIInterface);
    
    NSString *route = @"/blah/boo";
    NSString *methodName = @"DANNY";
    NSDictionary *params = @{@"foo": @3};
    MAVEHTTPCompletionBlock completionBlock = ^void(NSError *error, NSDictionary *responseData) {};
    
    OCMExpect([httpStackMock prepareJSONRequestWithRoute:route
                                              methodName:methodName
                                                  params:params
                                        preparationError:[OCMArg setTo:nil]]);
    OCMExpect([httpStackMock sendPreparedRequest:[OCMArg any] completionBlock:completionBlock]);
    OCMExpect([httpInterfaceMock addCustomUserHeadersToRequest:[OCMArg any]]);
    
    [self.testAPIInterface sendIdentifiedJSONRequestWithRoute:route
                                                    methodName:methodName
                                                        params:params
                                               completionBlock:completionBlock];
    OCMVerifyAll(httpStackMock);
    OCMVerifyAll(httpInterfaceMock);
}

- (void)testSendIdentifiedJSONRequestError {
    id httpStackMock = OCMPartialMock(self.testAPIInterface.httpStack);
    
    NSString *route = @"/blah/boo";
    NSString *methodName = @"DANNY";
    NSDictionary *params = @{@"foo": @3};
    NSError *expectedError = [[NSError alloc] init];
    
    OCMExpect([httpStackMock prepareJSONRequestWithRoute:route
                                              methodName:methodName
                                                  params:params
                                        preparationError:[OCMArg setTo:expectedError]]);

    // If error arrises, our block should be called with the error
    __block BOOL called;
    __block NSError *returnedError;
    __block NSDictionary *returnedData;
    [self.testAPIInterface sendIdentifiedJSONRequestWithRoute:route
                                                    methodName:methodName
                                                        params:params
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
                                       completionBlock:nil]);
    [self.testAPIInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:additionalParams];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    // When no user data set, the user id not added to the params
    [MaveSDK sharedInstance].userData = nil;
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:fakeRoute
                                            methodName:@"POST"
                                                params:additionalParams
                                       completionBlock:nil]);
    [self.testAPIInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:additionalParams];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    // When additional params are nil, params are empty
    mock = OCMPartialMock(self.testAPIInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:fakeRoute
                                            methodName:@"POST"
                                                params:@{}
                                       completionBlock:nil]);
    [self.testAPIInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:nil];
    OCMVerifyAll(mock);
    [mock stopMocking];
}

@end