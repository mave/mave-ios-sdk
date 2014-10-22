//
//  GRKHTTPManagerTests.m
//  GrowthKit
//
//  Created by dannycosson on 10/13/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "GRKConstants.h"
#import "GRKHTTPManager.h"
#import "GRKHTTPManager_Internal.h"

#import <OCMock/OCMock.h>

@interface GRKHTTPManagerTests : XCTestCase

@property (nonatomic, strong) GRKHTTPManager *httpManager;

@end

@implementation GRKHTTPManagerTests

- (void)setUp {
    [super setUp];
    
    // Set up http manager to use
    self.httpManager = [[GRKHTTPManager alloc] initWithApplicationId:@"foo123"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitSetsCorrectVaues {
    XCTAssertEqualObjects(self.httpManager.applicationId, @"foo123");
    XCTAssertEqualObjects(self.httpManager.baseURL, @"http://devaccounts.growthkit.io/v1.0");
    XCTAssertNotNil(self.httpManager.session);
    XCTAssertEqualObjects(self.httpManager.session.configuration.HTTPAdditionalHeaders, nil);
}

//
// Individual API Requests
//
- (void)testSendAppLaunchEvent {
    GRKHTTPManager *httpManager = [[GRKHTTPManager alloc] init];
    id mocked = [OCMockObject partialMockForObject:httpManager];
    [[mocked expect] sendIdentifiedJSONRequestWithRoute:@"/launch"
                                             methodType:@"POST"
                                                 params:@{}
                                        completionBlock:nil];
    [httpManager sendApplicationLaunchNotification];
    [mocked verify];
}

- (void)testSendUserSignupEvent {
    GRKHTTPManager *httpManager = [[GRKHTTPManager alloc] init];
    id mocked = [OCMockObject partialMockForObject:httpManager];
    NSDictionary *expectedParams = @{@"user_id": @"1", @"email": @"foo@bar.com", @"phone": @"18085551234"};
    [[mocked expect] sendIdentifiedJSONRequestWithRoute:@"/users"
                                             methodType:@"POST"
                                                 params:expectedParams
                                        completionBlock:nil];
    [httpManager sendUserSignupNotificationWithUserID:@"1" email:@"foo@bar.com" phone:@"18085551234"];
    [mocked verify];
}

- (void)testSendInvitePageOpenEvent {
    GRKHTTPManager *httpManager = [[GRKHTTPManager alloc] init];
    id mocked = [OCMockObject partialMockForObject:httpManager];
    NSDictionary *expectedParams = @{@"user_id": @"2"};
    [[mocked expect] sendIdentifiedJSONRequestWithRoute:@"/invite_page_open"
                                             methodType:@"POST"
                                                 params:expectedParams
                                        completionBlock:nil];
    [httpManager sendInvitePageOpen:@"2"];
    [mocked verify];
}

- (void)testSendInvitesEvent {
    GRKHTTPManager *httpManager = [[GRKHTTPManager alloc] init];
    id mocked = [OCMockObject partialMockForObject:httpManager];
    NSArray *recipients = @[@"18085551234", @"18085555678"];
    NSString *smsCopy = @"This is as test";
    NSString *userId = @"some-user-id";
    NSDictionary *expectedParams = @{@"recipients": recipients,
                                     @"sms_copy": smsCopy,
                                     @"sender_user_id": userId
                                   };
    [[mocked expect] sendIdentifiedJSONRequestWithRoute:@"/invites/sms"
                                             methodType:@"POST"
                                                 params:expectedParams
                                        completionBlock:nil];
    [httpManager sendInvitesWithPersons:recipients message:smsCopy userId:userId completionBlock:nil];
    [mocked verify];
}


//
// Underlying request sending infrastructure
//

- (void)testSendIdentifiedJSONRequestSuccess {
    // Setup mock and block to get data out of the request
    GRKHTTPManager *httpManager = [[GRKHTTPManager alloc] initWithApplicationId:@"appid12"];
    id mockSession = [OCMockObject mockForClass:[NSURLSession class]];
    id mockTask = [OCMockObject mockForClass:[NSURLSessionTask class]];
    httpManager.session = mockSession;
    __block NSString *urlString;
    __block NSString *requestMethod;
    __block NSString *requestBodyParams;
    __block NSDictionary *requestHeaders;
    NSString *requestPath = @"/foo";
    NSDictionary *requestDict = @{@"foo": @2, @"bar": @YES};
    OCMStub([mockSession dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSURLRequest *request = (NSURLRequest *)obj;
        urlString = [request.URL absoluteString];
        requestMethod = request.HTTPMethod;
        requestBodyParams = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:kNilOptions error:nil];
        requestHeaders = request.allHTTPHeaderFields;
        return YES;
    }] completionHandler:[OCMArg any]]).andReturn(mockTask);
    OCMExpect([mockTask resume]);

    // Call the send method
    [httpManager sendIdentifiedJSONRequestWithRoute:requestPath methodType:@"POST" params:requestDict completionBlock:nil];

    // Verify
    OCMVerify([mockTask resume]);
    XCTAssertEqualObjects(urlString, @"http://devaccounts.growthkit.io/v1.0/foo");
    XCTAssertEqualObjects(requestMethod, @"POST");
    XCTAssertEqualObjects(requestBodyParams, requestDict);
    NSDictionary *expectedHeaders = @{@"Content-Type": @"application/json; charset=utf-8",
                                      @"Accept": @"application/json",
                                      @"X-Application-ID": @"appid12",
                                      };
    XCTAssertEqualObjects(requestHeaders, expectedHeaders);
}

- (void)testGetHTTPStatusCodeLevel {
    NSInteger code = 200;
    NSInteger codeLevel = code / 100;
    XCTAssertEqual(codeLevel, 2);
    code = 201;
    codeLevel = code / 100;
    XCTAssertEqual(codeLevel, 2);
    code = 299;
    codeLevel = code / 100;
    XCTAssertEqual(codeLevel, 2);
}

//
// Tests for errors in building Request
//
- (void)testSendIdentifiedJSONRequestWithBadJSONfails {
    // Object is invalid for JSON
    __block NSError *returnedError;
    __block NSDictionary *returnedDict;
    [self.httpManager sendIdentifiedJSONRequestWithRoute:@"/foo" methodType:@"POST" params:nil completionBlock:^(NSError *error, NSDictionary *responseData) {
        returnedError = error;
        returnedDict = responseData;
    }];
    XCTAssertEqual([returnedDict count], 0);
    XCTAssertEqual([returnedError code], GRKHTTPErrorRequestJSONCode);
}

- (NSData *)failingDataWithJSONObject:(id)params options:(NSJSONWritingOptions)options error:(NSError **)error {
    *error = [[NSError alloc] init];
    return nil;
}

- (void)testSendIdentifiedJSONRequestWithInternalJSONFailure {
    // Internal error when encoding JSON
    // Swizzle the methods to force the error
    Method ogMethod = class_getClassMethod([NSJSONSerialization class], @selector(dataWithJSONObject:options:error:));
    Method mockMethod = class_getInstanceMethod([self class], @selector(failingDataWithJSONObject:options:error:));
    method_exchangeImplementations(ogMethod, mockMethod);
    
    // Make call to run test
    __block NSError *returnedError = nil;
    __block NSDictionary *returnedDict = nil;
    [self.httpManager sendIdentifiedJSONRequestWithRoute:@"/foo" methodType:@"POST" params:@{} completionBlock:^(NSError *error, NSDictionary *responseData) {
        returnedError = error;
        returnedDict = responseData;
    }];
    XCTAssertEqual([returnedDict count], 0);
    XCTAssertEqual([returnedError code], GRKHTTPErrorRequestJSONCode);
}

//
// Tests for response handler
//
- (void)testHandleSuccessJSONResponseWithData {
    NSDictionary *dataDict = @{@"foo": @2, @"bar": @"yes", @"baz": @YES};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    
    NSURL *url = [NSURL URLWithString:@"http://example.com/foo"];
    NSDictionary *headers = @{@"Content-Type": @"application/json"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.1" headerFields:headers];

    __block NSDictionary *returnedData;
    __block NSError *returnedError;
    [GRKHTTPManager handleJSONResponseWithData:data response:response error:nil completionBlock:^(NSError *error, NSDictionary *responseData) {
        returnedError = error;
        returnedData = responseData;
    }];
    XCTAssertEqualObjects(returnedData, dataDict);
    XCTAssertEqualObjects(returnedError, nil);
}

- (void)testHandleInvalidJSONResponse {
    NSData *data = [@"{\"this is not json" dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:@"http://example.com/foo"];
    NSDictionary *headers = @{@"Content-Type": @"application/json"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.1" headerFields:headers];

    __block NSDictionary *returnedData;
    __block NSError *returnedError;
    [GRKHTTPManager handleJSONResponseWithData:data response:response error:nil completionBlock:^(NSError *error, NSDictionary *responseData) {
        returnedError = error;
        returnedData = responseData;
    }];
    XCTAssertEqualObjects(returnedData, nil);
    XCTAssertEqual([returnedError code], GRKHTTPErrorResponseJSONCode);
}

- (void)testHandleNonJSONResponse {
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:kNilOptions error:nil];
    
    NSURL *url = [NSURL URLWithString:@"http://example.com/foo"];
    NSDictionary *headers = @{@"Content-Type": @"text/html"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.1" headerFields:headers];
    
    __block NSDictionary *returnedData;
    __block NSError *returnedError;
    [GRKHTTPManager handleJSONResponseWithData:data response:response error:nil completionBlock:^(NSError *error, NSDictionary *responseData) {
        returnedError = error;
        returnedData = responseData;
    }];
    XCTAssertEqualObjects(returnedData, nil);
    XCTAssertEqual([returnedError code], GRKHTTPErrorResponseIsNotJSONCode);
}

- (void)testHandle400LevelResponse {
    // Authentication Errors and the like
    NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:@"http://example.com/foo"];
    NSDictionary *headers = @{@"Content-Type": @"application/json"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:401 HTTPVersion:@"1.1" headerFields:headers];
    
    __block NSDictionary *returnedData;
    __block NSError *returnedError;
    [GRKHTTPManager handleJSONResponseWithData:data response:response error:nil completionBlock:^(NSError *error, NSDictionary *responseData) {
        returnedError = error;
        returnedData = responseData;
    }];
    XCTAssertEqualObjects(returnedData, nil);
    XCTAssertEqual([returnedError code], GRKHTTPErrorResponse400LevelCode);
}

- (void)testHandle500LevelResponse {
    // Authentication Errors and the like
    NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:@"http://example.com/foo"];
    NSDictionary *headers = @{@"Content-Type": @"application/json"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:504 HTTPVersion:@"1.1" headerFields:headers];
    
    __block NSDictionary *returnedData;
    __block NSError *returnedError;
    [GRKHTTPManager handleJSONResponseWithData:data response:response error:nil completionBlock:^(NSError *error, NSDictionary *responseData) {
        returnedError = error;
        returnedData = responseData;
    }];
    XCTAssertEqualObjects(returnedData, nil);
    XCTAssertEqual([returnedError code], GRKHTTPErrorResponse500LevelCode);
}

- (void)testHandleNilResponse {
    // Authentication Errors and the like
    NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    NSHTTPURLResponse *response = nil;
    
    __block NSDictionary *returnedData;
    __block NSError *returnedError;
    [GRKHTTPManager handleJSONResponseWithData:data response:response error:nil completionBlock:^(NSError *error, NSDictionary *responseData) {
        returnedError = error;
        returnedData = responseData;
    }];
    XCTAssertEqualObjects(returnedData, nil);
    XCTAssertEqual([returnedError code], GRKHTTPErrorResponseNilCode);
}

- (void)testHandleResponseWithNilCompletionBlockDoesNothing {
    NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:@"http://example.com/foo"];
    NSDictionary *headers = @{@"Content-Type": @"application/json"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:504 HTTPVersion:@"1.1" headerFields:headers];

    // Shouldn't throw an error
    [GRKHTTPManager handleJSONResponseWithData:data
                                      response:response
                                         error:nil
                               completionBlock:nil];
}


@end