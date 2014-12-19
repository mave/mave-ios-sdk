//
//  MAVEPreFetchedHTTPRequestTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/19/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEPreFetchedHTTPRequest.h"

@interface MAVEPreFetchedHTTPRequestTests : XCTestCase

@end

@implementation MAVEPreFetchedHTTPRequestTests

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
    MAVEPreFetchedHTTPRequest *req = [[MAVEPreFetchedHTTPRequest alloc] initWithDefaultData:defaultData];
    XCTAssertEqualObjects(req.defaultData, defaultData);
    XCTAssertEqualObjects(req.responseData, defaultData);
    XCTAssertNotNil(req.gcd_semaphore);
}

- (void)testSetDataOverwritesDefault {
    NSDictionary *defaultData = @{@"foo": @"bar"};
    NSDictionary *newData = @{@"foo": @"baz"};
    MAVEPreFetchedHTTPRequest *req = [[MAVEPreFetchedHTTPRequest alloc] initWithDefaultData:defaultData];
    req.responseData = newData;
    XCTAssertNotEqualObjects(req.responseData, defaultData);
    XCTAssertEqualObjects(req.responseData, newData);
    // default data is unchanged
    XCTAssertEqualObjects(req.defaultData, defaultData);
}

// ResponseData being nil is fine, and different than "doNotSet" it
- (void)testSetDataCanOverwriteWithNil {
    NSDictionary *defaultData = @{@"foo": @"bar"};
    NSDictionary *newData = nil;
    MAVEPreFetchedHTTPRequest *req = [[MAVEPreFetchedHTTPRequest alloc] initWithDefaultData:defaultData];
    req.responseData = newData;
    XCTAssertNil(req.responseData);
    XCTAssertEqualObjects(req.defaultData, defaultData);
}

- (void)testDoNotSetDataDoesNotOverrideDefault {
    NSDictionary *defaultData = @{@"foo": @"bar"};
    MAVEPreFetchedHTTPRequest *req = [[MAVEPreFetchedHTTPRequest alloc] initWithDefaultData:defaultData];
    [req doNotSetResponseData];
    XCTAssertEqualObjects(req.responseData, defaultData);
}

// If we read data successfully, we have data and semaphore gets re-signalled
- (void)testReadDataSuccess {
    NSDictionary *defaultData = @{@"foo": @0};
    NSDictionary *newData = @{@"foo": @1};
    MAVEPreFetchedHTTPRequest *req = [[MAVEPreFetchedHTTPRequest alloc] initWithDefaultData:defaultData];
    req.responseData = newData;

    [req readDataWithTimeout:0 completionBlock:^(NSDictionary *responseData) {
        XCTAssertEqualObjects(responseData, newData);
    }];
    // since semaphore was re-signalled, we can get it now with no wait
    XCTAssertEqual(dispatch_semaphore_wait(req.gcd_semaphore, 0), 0);
}

// If read-data timeout, the semaphore does not get re-signalled
- (void)testReadDataTimeout {
    NSDictionary *defaultData = @{@"foo": @0};
    MAVEPreFetchedHTTPRequest *req = [[MAVEPreFetchedHTTPRequest alloc] initWithDefaultData:defaultData];
    
    [req readDataWithTimeout:0 completionBlock:^(NSDictionary *responseData) {
        XCTAssertEqualObjects(responseData, defaultData);
    }];
    // since semaphore was not re-signalled, it still blocks
    XCTAssertNotEqual(dispatch_semaphore_wait(req.gcd_semaphore, 0), 0);
}

@end
