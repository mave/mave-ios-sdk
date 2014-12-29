//
//  MAVEPreFetchedHTTPRequestTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/19/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEPendingResponseData.h"

@interface MAVEPendingResponseDataTests : XCTestCase

@end

@implementation MAVEPendingResponseDataTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithDefaultData {
    NSDictionary *defaultData = @{@"foo": @"bar"};
    MAVEPendingResponseData *data =
        [[MAVEPendingResponseData alloc] initWithDefaultData:defaultData];
    XCTAssertEqualObjects(data.defaultData, defaultData);
    XCTAssertEqualObjects(data.responseData, defaultData);
    XCTAssertNotNil(data.gcd_semaphore);
}

- (void)testSetDataOverwritesDefault {
    NSDictionary *defaultData = @{@"foo": @"bar"};
    NSDictionary *newData = @{@"foo": @"baz"};
    MAVEPendingResponseData *data =
        [[MAVEPendingResponseData alloc] initWithDefaultData:defaultData];
    data.responseData = newData;
    XCTAssertNotEqualObjects(data.responseData, defaultData);
    XCTAssertEqualObjects(data.responseData, newData);
    // default data is unchanged
    XCTAssertEqualObjects(data.defaultData, defaultData);
}

// ResponseData being nil is fine, and different than "doNotSet" it
- (void)testSetDataCanOverwriteWithNil {
    NSDictionary *defaultData = @{@"foo": @"bar"};
    NSDictionary *newData = nil;
    MAVEPendingResponseData *data =
        [[MAVEPendingResponseData alloc] initWithDefaultData:defaultData];
    data.responseData = newData;
    XCTAssertNil(data.responseData);
    XCTAssertEqualObjects(data.defaultData, defaultData);
}

- (void)testDoNotSetDataDoesNotOverrideDefault {
    NSDictionary *defaultData = @{@"foo": @"bar"};
    MAVEPendingResponseData *data =
        [[MAVEPendingResponseData alloc] initWithDefaultData:defaultData];
    [data doNotSetResponseData];
    XCTAssertEqualObjects(data.responseData, defaultData);
}

// If we read data successfully, we have data and semaphore gets re-signalled
- (void)testReadDataSuccess {
    NSDictionary *defaultData = @{@"foo": @0};
    NSDictionary *newData = @{@"foo": @1};
    MAVEPendingResponseData *req =
        [[MAVEPendingResponseData alloc] initWithDefaultData:defaultData];
    req.responseData = newData;

    [req readDataWithTimeout:0 completionBlock:^(NSDictionary *responseData, NSDictionary *defaultData) {
        XCTAssertEqualObjects(responseData, newData);
        XCTAssertEqualObjects(defaultData, defaultData);
    }];
    // since semaphore was re-signalled, we can get it now with no wait
    XCTAssertEqual(dispatch_semaphore_wait(req.gcd_semaphore, 0), 0);
}

// If read-data timeout, the semaphore does not get re-signalled
- (void)testReadDataTimeout {
    NSDictionary *defaultData1 = @{@"foo": @0};
    MAVEPendingResponseData *req =
        [[MAVEPendingResponseData alloc] initWithDefaultData:defaultData1];
    
    [req readDataWithTimeout:0 completionBlock:^(NSDictionary *responseData, NSDictionary *defaultData) {
        XCTAssertEqualObjects(responseData, defaultData);
        XCTAssertEqualObjects(defaultData, defaultData1);
    }];
    // since semaphore was not re-signalled, it still blocks
    XCTAssertNotEqual(dispatch_semaphore_wait(req.gcd_semaphore, 0), 0);
}

@end
