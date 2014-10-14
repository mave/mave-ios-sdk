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

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <URLMock/URLMock.h>

@interface GRKNetworkManagerTests : XCTestCase

@property (nonatomic, strong) GRKHTTPManager *networkManager;

@end

@implementation GRKNetworkManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.networkManager = [[GRKHTTPManager alloc] initWithApplicationId:@"foo123"];
    NSURLSessionConfiguration *config = self.networkManager.session.configuration;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitSetsCorrectVaues {
    XCTAssertEqualObjects(self.networkManager.applicationId, @"foo123");
    XCTAssertEqualObjects(self.networkManager
                          .baseURL, @"http://devaccounts.growthkit.io/v1.0");
    XCTAssertNotNil(self.networkManager
                    .session);
    NSDictionary *expectedAdditionalHeaders = @{@"Accept": @"application/json"};
    XCTAssertEqualObjects(self.networkManager
                          .session.configuration.HTTPAdditionalHeaders,
                          expectedAdditionalHeaders);
}

- (void)testSendIdentifiedJSONRequest {
    self.networkManager
    
//    NSMutableArray *mockArray = mock([NSMutableArray class]);
//    NSURLSessionTask *mockSessionTask = mock([NSURLSessionTask class]);
//    [given([mockSessionTask resume]) willReturn@"foo"];
    
}



@end
