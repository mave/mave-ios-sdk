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

#import <OCMockito/OCMockito.h>

@interface GRKNetworkManagerTests : XCTestCase

@end

@implementation GRKNetworkManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitSetsCorrectVaues {
    GRKHTTPManager *nm = [[GRKHTTPManager alloc] initWithApplicationId:@"foo123"];
    XCTAssertEqualObjects(nm.applicationId, @"foo123");
    XCTAssertEqualObjects(nm.baseURL, @"http://devaccounts.growthkit.io/v1.0");
    XCTAssertNotNil(nm.session);
    NSDictionary *expectedAdditionalHeaders = @{@"Accept": @"application/json"};
    XCTAssertEqualObjects(nm.session.configuration.HTTPAdditionalHeaders,
                          expectedAdditionalHeaders);
}

- (void)testSendIdentifiedJSONRequest {
    
}



@end
