//
//  GRKHTTPManagerTests.m
//  GrowthKit
//
//  Created by dannycosson on 10/13/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
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
    [self.httpManager sendIdentifiedJSONRequestWithRoute:requestPath methodType:@"POST" params:requestDict completionBlock:^(NSInteger statusCode, NSDictionary *responseData) {
        NSLog(@"Headers expected: %@", expectedRequestHeaders);
        completionBlockRan = YES;
    }];
    
    UMKAssertTrueBeforeTimeout(0.1,
                               [[UMKMockURLProtocol servicedRequests] count] == 1,
                               @"request didn't match stub");
    UMKAssertTrueBeforeTimeout(0.1, completionBlockRan, @"block ran");
}

- (void)testHandleSuccessJSONResponseWithData {
    NSDictionary *dataDict = @{@"foo": @2, @"bar": @"yes", @"baz": @YES};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];

    NSURL *url = [NSURL URLWithString:@"http://example.com/foo"];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.1" headerFields:@{}];

    __block NSInteger returnedStatusCode;
    __block NSDictionary *returnedData;
    [GRKHTTPManager handleJSONResponseWithData:data response:response error:nil completionBlock:^(NSInteger statusCode, NSDictionary *responseData) {
        returnedStatusCode = statusCode;
        returnedData = responseData;
    }];
    XCTAssertEqualObjects(returnedData, dataDict);
    XCTAssertEqual(returnedStatusCode, 200);
}


@end