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
#import "MAVEHTTPInterface.h"
#import "MAVEClientPropertyUtils.h"

@interface MAVEHTTPInterfaceTests : XCTestCase

@property MAVEHTTPInterface *testHTTPInterface;

@end

@implementation MAVEHTTPInterfaceTests

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
    self.testHTTPInterface = [[MAVEHTTPInterface alloc] init];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitAndCurrentUserProperties {
    XCTAssertEqualObjects(self.testHTTPInterface.httpStack.baseURL, @"http://devapi.mave.io/v1.0");
    XCTAssertEqualObjects(self.testHTTPInterface.applicationID, [MaveSDK sharedInstance].appId);
    XCTAssertEqualObjects(self.testHTTPInterface.applicationDeviceID, [MaveSDK sharedInstance].appDeviceID);
    XCTAssertEqualObjects(self.testHTTPInterface.userData, [MaveSDK sharedInstance].userData);
}

///
/// Specific tracking events
///
- (void)testTrackAppOpen {
    id mock = OCMPartialMock(self.testHTTPInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackAppLaunch additionalParams:nil]);
    [self.testHTTPInterface trackAppOpen];
    OCMVerifyAll(mock);
}

- (void)testTrackSignup {
    id mock = OCMPartialMock(self.testHTTPInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackSignup additionalParams:nil]);
    [self.testHTTPInterface trackSignup];
    OCMVerifyAll(mock);
}

- (void)testTrackInvitePageOpen {
    // With a value
    NSString *type = @"blahblahtype";
    id mock = OCMPartialMock(self.testHTTPInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                                  additionalParams:@{MAVEParamKeyInvitePageType: type}]);
    [self.testHTTPInterface trackInvitePageOpenForPageType:type];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    // nil and empty string get set as unknown
    mock = OCMPartialMock(self.testHTTPInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                                  additionalParams:@{MAVEParamKeyInvitePageType: @"unknown"}]);
    [self.testHTTPInterface trackInvitePageOpenForPageType:nil];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    mock = OCMPartialMock(self.testHTTPInterface);
    OCMExpect([mock trackGenericUserEventWithRoute:MAVERouteTrackInvitePageOpen
                                  additionalParams:@{MAVEParamKeyInvitePageType: @"unknown"}]);
    [self.testHTTPInterface trackInvitePageOpenForPageType:@""];
    OCMVerifyAll(mock);
    [mock stopMocking];
}

///
/// Other specific requests
///
- (void)testIdentifyUserRequest {
    MAVEHTTPManager *httpManager = [[MAVEHTTPManager alloc] init];
    id mocked = [OCMockObject partialMockForObject:httpManager];
    MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Dan" lastName:@"Foo" email:@"foo@bar.com" phone:@"18085551234"];
    NSDictionary *expectedParams = @{@"user_id": userData.userID,
                                     @"first_name": userData.firstName,
                                     @"last_name": userData.lastName,
                                     @"email": userData.email,
                                     @"phone": userData.phone};
    [[mocked expect] sendIdentifiedJSONRequestWithRoute:@"/users"
                                             methodType:@"PUT"
                                                 params:expectedParams
                                        completionBlock:nil];
    [httpManager identifyUserRequest:userData];
    OCMVerifyAll(mocked);
}

- (void)testIdentifyUserWithMinimalParams {
    // user id is the only property of the user data required to be non-nil to make the identify user request
    id mocked = OCMPartialMock(self.testHTTPInterface);
    [MaveSDK sharedInstance].userData = [[MAVEUserData alloc] init];
    // user id is missing so request will fail but it will still get attempted
    NSDictionary *expectedParams = @{};
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/users"
                                             methodName:@"PUT"
                                                 params:expectedParams
                                        completionBlock:nil]);
    [self.testHTTPInterface identifyUser];
    OCMVerifyAll(mocked);
}

- (void)testSendInvites {
    id mocked = OCMPartialMock(self.testHTTPInterface);
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
    [self.testHTTPInterface sendInvitesWithPersons:recipients
                                           message:smsCopy
                                            userId:userId
                          inviteLinkDestinationURL:linkDestination
                                   completionBlock:nil];
    OCMVerifyAll(mocked);
}

- (void)testSendInvitesLinkDestinationOmittedIfEmpty {
    id mocked = OCMPartialMock(self.testHTTPInterface);
    NSString *linkDestination = nil;
    NSDictionary *expectedParams = @{@"recipients": @[],
                                     @"sms_copy": @"",
                                     @"sender_user_id": @"",
                                     };
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/invites/sms"
                                             methodName:@"POST"
                                                 params:expectedParams
                                        completionBlock:nil]);
    [self.testHTTPInterface sendInvitesWithPersons:@[]
                                           message:@""
                                            userId:@""
                          inviteLinkDestinationURL:linkDestination
                                   completionBlock:nil];
    OCMVerifyAll(mocked);
}

- (void)testGetReferringUser {
    id mocked = OCMPartialMock(self.testHTTPInterface);
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
    [self.testHTTPInterface getReferringUser:^(MAVEUserData *_userData) {
        userData = _userData;
    }];
    OCMVerifyAll(mocked);
    XCTAssertEqualObjects(userData.userID, @"1");
    XCTAssertEqualObjects(userData.firstName, @"dan");
}

- (void)testGetReferringUserNull {
    // Same as above test, but this time the data returned from the server is nil
    id mocked = OCMPartialMock(self.testHTTPInterface);
    OCMExpect([mocked sendIdentifiedJSONRequestWithRoute:@"/referring_user"
                                              methodName:@"GET"
                                                  params:nil
                                         completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSDictionary *fakeResponseData = nil;
        ((void(^)(NSError *error, NSDictionary *responseData)) obj)(nil, fakeResponseData);
        return YES;
    }]]);
    __block MAVEUserData *userData;
    [self.testHTTPInterface getReferringUser:^(MAVEUserData *_userData) {
        userData = _userData;
    }];
    [mocked verify];
    
    XCTAssertNil(userData);
}

- (void)testPreFetchRemoteConfiguration {
    NSURLRequest *req = [[NSURLRequest alloc] init];
    NSDictionary *defaultResponse = @{@"foo": @1};
    
    id mock = OCMPartialMock(self.testHTTPInterface.httpStack);
    OCMExpect([mock prepareJSONRequestWithRoute:@"/remote_configuration/ios"
                                       methodName:@"GET"
                                           params:nil preparationError:[OCMArg setTo:nil]])
    .andReturn(req);
    
    OCMExpect([mock preFetchPreparedRequest:req defaultData:defaultResponse]);
    
    [self.testHTTPInterface preFetchRemoteConfiguration:defaultResponse];
    
    OCMVerifyAll(mock);
}


///
/// Request building logic
///
- (void)testAddCustomUserHeadersToRequest {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    XCTAssertEqual([req.allHTTPHeaderFields count], 0);
    
    [self.testHTTPInterface addCustomUserHeadersToRequest:req];
    NSDictionary *headers = req.allHTTPHeaderFields;
    XCTAssertEqual([headers count], 5);
    XCTAssertEqualObjects([headers objectForKey:@"X-Application-Id"],
                          [MaveSDK sharedInstance].appId);
    XCTAssertEqualObjects([headers objectForKey:@"X-App-Device-Id"],
                          [MaveSDK sharedInstance].appDeviceID);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSString *expectedDimensions = [NSString stringWithFormat:@"%ldx%ld",
                                    (long)screenSize.width, (long)screenSize.height];
    NSString *expectedUserAgent = [MAVEHTTPManager userAgentWithUIDevice:[UIDevice currentDevice]];
    NSString *expectedClientProperties = [MAVEClientPropertyUtils encodedAutomaticClientProperties];
    XCTAssertEqualObjects([headers objectForKey:@"X-Device-Screen-Dimensions"],
                          expectedDimensions);
    XCTAssertEqualObjects([headers objectForKey:@"User-Agent"], expectedUserAgent);
    XCTAssertEqualObjects([headers objectForKey:@"X-Client-Properties"], expectedClientProperties);
}

- (void)testSendIdentifiedJSONRequestSuccess {
    id httpStackMock = OCMPartialMock(self.testHTTPInterface.httpStack);
    id httpInterfaceMock = OCMPartialMock(self.testHTTPInterface);
    
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
    
    [self.testHTTPInterface sendIdentifiedJSONRequestWithRoute:route
                                                    methodName:methodName
                                                        params:params
                                               completionBlock:completionBlock];
    OCMVerifyAll(httpStackMock);
    OCMVerifyAll(httpInterfaceMock);
}

- (void)testSendIdentifiedJSONRequestError {
    id httpStackMock = OCMPartialMock(self.testHTTPInterface.httpStack);
    
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
    [self.testHTTPInterface sendIdentifiedJSONRequestWithRoute:route
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
    id mock = OCMPartialMock(self.testHTTPInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:fakeRoute
                                            methodName:@"POST"
                                                params:expectedParams
                                       completionBlock:nil]);
    [self.testHTTPInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:additionalParams];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    // When no user data set, the user id not added to the params
    [MaveSDK sharedInstance].userData = nil;
    mock = OCMPartialMock(self.testHTTPInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:fakeRoute
                                            methodName:@"POST"
                                                params:additionalParams
                                       completionBlock:nil]);
    [self.testHTTPInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:additionalParams];
    OCMVerifyAll(mock);
    [mock stopMocking];
    
    // When additional params are nil, params are empty
    mock = OCMPartialMock(self.testHTTPInterface);
    OCMExpect([mock sendIdentifiedJSONRequestWithRoute:fakeRoute
                                            methodName:@"POST"
                                                params:@{}
                                       completionBlock:nil]);
    [self.testHTTPInterface trackGenericUserEventWithRoute:fakeRoute additionalParams:nil];
    OCMVerifyAll(mock);
    [mock stopMocking];
}

@end