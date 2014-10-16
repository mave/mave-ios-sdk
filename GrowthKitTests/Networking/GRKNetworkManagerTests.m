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

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <URLMock/URLMock.h>


@interface GRKNetworkManagerTests : XCTestCase

@property (nonatomic, strong) GRKHTTPManager *httpManager;

@end

@implementation GRKNetworkManagerTests

- (void)setUp {
    [super setUp];
    
    // Set up URLMock & tell it to use fake session
    [UMKMockURLProtocol reset];
    [UMKMockURLProtocol enable];
    [UMKMockURLProtocol setVerificationEnabled:YES];
    self.httpManager = [[GRKHTTPManager alloc] initWithApplicationId:@"foo123"];
    NSURLSessionConfiguration *config = self.httpManager.session.configuration;
    config.protocolClasses = @[ [UMKMockURLProtocol class] ];
    self.httpManager.session = [NSURLSession sessionWithConfiguration:config];
    
}

- (void)tearDown {
    [UMKMockURLProtocol setVerificationEnabled:NO];
    [UMKMockURLProtocol disable];
    [super tearDown];
}

- (void)testInitSetsCorrectVaues {
    XCTAssertEqualObjects(self.httpManager.applicationId, @"foo123");
    XCTAssertEqualObjects(self.httpManager.baseURL, @"http://devaccounts.growthkit.io/v1.0");
    XCTAssertNotNil(self.httpManager.session);
    NSDictionary *expectedAdditionalHeaders = @{@"Accept": @"application/json"};
    XCTAssertEqualObjects(self.httpManager.session.configuration.HTTPAdditionalHeaders,
                          expectedAdditionalHeaders);
}

// TODO - DC: needs to capture the headers as well
- (void)testSendIdentifiedJSONRequest {
    // Build Request
    NSString *requestPath = @"/foo";
    NSDictionary *requestDict = @{@"foo": @2, @"bar": @YES};
    
    // Build Mock/Stub with expected values
    NSURL *url = [NSURL URLWithString: [self.httpManager.baseURL stringByAppendingString:requestPath]];
//    NSDictionary *responseDict = @{@"ok": @"yes"};
//    NSData *responseJSON = [NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:nil];
    NSDictionary *expectedRequestHeaders = @{@"Accept": @"application/json",
                                             @"Content-Type": @"application/json; charset=utf-8",
                                             };
    
    UMKMockHTTPRequest *mockRequest = [[UMKMockHTTPRequest alloc] initWithHTTPMethod:@"POST" URL:url checksHeadersWhenMatching:NO checksBodyWhenMatching:YES];
    [mockRequest setBodyWithJSONObject:requestDict];
    [mockRequest setHeaders:expectedRequestHeaders];
    mockRequest.responder = [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:200];
//    [UMKMockHTTPResponder mockHTTPResponderWithStatusCode:200 body:responseJSON];
    [UMKMockURLProtocol expectMockRequest:mockRequest];
    
    // Run request and capture necessary variables
    __block BOOL completionBlockRan = NO;
//    __block NSDictionary *returnedDict = nil;
    [self.httpManager sendIdentifiedJSONRequestWithRoute:requestPath methodType:@"POST" params:requestDict completionBlock:^(NSError *error, NSDictionary *responseData) {
        NSLog(@"Headers expected: %@", expectedRequestHeaders);
        completionBlockRan = YES;
    }];
    
    UMKAssertTrueBeforeTimeout(0.1,
                               [[UMKMockURLProtocol servicedRequests] count] == 1,
                               @"request didn't match stub");
    UMKAssertTrueBeforeTimeout(0.1, completionBlockRan, @"block ran");
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
// Tests for formatting request data & parsing response
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


@end