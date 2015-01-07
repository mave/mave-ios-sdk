//
//  MAVEPromiseWithDefaultTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEPromiseWithDefault.h"
#import "MAVEPromiseWithDefault_Internal.h"

@interface MAVEPromiseWithDefaultTests : XCTestCase

@end

@implementation MAVEPromiseWithDefaultTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testInitWithDefaultValue {
    NSValue *defaultData = (NSValue *)@"foo";
    MAVEPromiseWithDefault *promise = [[MAVEPromiseWithDefault alloc] initWithDefaultValue:defaultData];
    XCTAssertEqualObjects(promise.defaultValue, defaultData);
    XCTAssertEqualObjects(promise.fulfilledValue, nil);
    XCTAssertEqual(promise.status, MAVEPromiseStatusUnfulfilled);
}

- (void)testFulfillAndGetValue {
    NSValue *defaultValue = (NSValue *)@"foo";
    NSValue *fulfilledValue = (NSValue *)@"bar";
    MAVEPromiseWithDefault *promise = [[MAVEPromiseWithDefault alloc] initWithDefaultValue:defaultValue];

    promise.fulfilledValue = fulfilledValue;
    XCTAssertEqualObjects(promise.fulfilledValue, fulfilledValue);
    XCTAssertEqualObjects(promise.defaultValue, defaultValue);
    XCTAssertEqual(promise.status, MAVEPromiseStatusFulfilled);

    [promise valueWithTimeout:0
    completionBlock:^(NSValue *value) {
        XCTAssertEqual(value, fulfilledValue);
        XCTAssertEqualObjects(promise.defaultValue, defaultValue);
    }];
}

- (void)testRejectAndGetValue {
    NSValue *defaultValue = (NSValue *)@"foo";
    MAVEPromiseWithDefault *promise = [[MAVEPromiseWithDefault alloc] initWithDefaultValue:defaultValue];

    [promise reject];
    XCTAssertEqualObjects(promise.fulfilledValue, nil);
    XCTAssertEqualObjects(promise.defaultValue, defaultValue);
    XCTAssertEqual(promise.status, MAVEPromiseStatusRejected);

    [promise valueWithTimeout:0
    completionBlock:^(NSValue *value) {
        XCTAssertEqual(value, defaultValue);
    }];
    // since semaphore was re-signalled, we can get it now with no wait
    XCTAssertEqual(dispatch_semaphore_wait(promise.gcd_semaphore, 0), 0);
}

// If read-data timeout, the semaphore does not get re-signalled
- (void)testGetValueTimeout {
    NSValue *defaultValue = (NSValue *)@"foo";
    MAVEPromiseWithDefault *promise = [[MAVEPromiseWithDefault alloc] initWithDefaultValue:defaultValue];
    [promise valueWithTimeout:0
    completionBlock:^(NSValue *value) {
        XCTAssertEqualObjects(value, defaultValue);
        XCTAssertNil(promise.fulfilledValue);
    }];
    // since semaphore was not re-signalled, it still blocks
    XCTAssertNotEqual(dispatch_semaphore_wait(promise.gcd_semaphore, 0), 0);
}


@end
