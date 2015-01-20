//
//  MAVEPromiseTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEPromise.h"
#import "MAVEPromise_Internal.h"

@interface MAVEPromiseTests : XCTestCase

@end

@implementation MAVEPromiseTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    // Should create the promise and run the block
    __block MAVEPromise *calledWithPromise;
    MAVEPromise *promise = [[MAVEPromise alloc] initWithBlock:^(MAVEPromise *promise) {
        calledWithPromise = promise;
    }];

    XCTAssertNotNil(promise);
    XCTAssertNil(promise.value);
    XCTAssertEqual(promise.status, MAVEPromiseStatusUnfulfilled);
    XCTAssertEqualObjects(promise, calledWithPromise);

    // assert the semaphone is not available to get
    NSInteger result = dispatch_semaphore_wait(promise.gcd_semaphore, 0);
    XCTAssertNotEqual(result, 0);
}

- (void)testInitWithPreFetchBlockNil {
    // Should create the promise and not crash trying to call a nil block
    MAVEPromise *promise = [[MAVEPromise alloc] initWithBlock:nil];

    XCTAssertNotNil(promise);
    XCTAssertNil(promise.value);
    XCTAssertEqual(promise.status, MAVEPromiseStatusUnfulfilled);

    // assert the semaphone is not available to get
    NSInteger result = dispatch_semaphore_wait(promise.gcd_semaphore, 0);
    XCTAssertNotEqual(result, 0);
}

- (void)testFulfill {
    // Should create the promise and run the block
    NSValue *returnValue = (NSValue *)@"foo";
    MAVEPromise *promise = [[MAVEPromise alloc] initWithBlock:^(MAVEPromise *promise) {
        [promise fulfillPromise:returnValue];
    }];

    XCTAssertEqual(promise.status, MAVEPromiseStatusFulfilled);
    XCTAssertEqualObjects(promise.value, returnValue);

    // assert the semaphone is now available to get
    NSInteger result = dispatch_semaphore_wait(promise.gcd_semaphore, 0);
    XCTAssertEqual(result, 0);
}

- (void)testReject {
    // Should create the promise and run the block
    MAVEPromise *promise = [[MAVEPromise alloc] initWithBlock:^(MAVEPromise *promise) {
        [promise rejectPromise];
    }];

    XCTAssertEqual(promise.status, MAVEPromiseStatusRejected);
    XCTAssertNil(promise.value);

    // assert the semaphone is now available to get
    NSInteger result = dispatch_semaphore_wait(promise.gcd_semaphore, 0);
    XCTAssertEqual(result, 0);
}

- (void)testDoneSynchronous {
    // Should create the promise and run the block
    NSValue *returnValue = (NSValue *)@"fooasdf";
    MAVEPromise *promise = [[MAVEPromise alloc] initWithBlock:^(MAVEPromise *promise) {
        [promise fulfillPromise:returnValue];
    }];

    // Check that we can read it twice without timeing out
    NSValue *val = [promise doneSynchronousWithTimeout:2000];
    XCTAssertEqualObjects(val, returnValue);

    val = [promise doneSynchronousWithTimeout:2000];
    XCTAssertEqualObjects(val, returnValue);
}

- (void)testDoneWhenFailed {
    // Should create the promise and run the block
    MAVEPromise *promise = [[MAVEPromise alloc] initWithBlock:^(MAVEPromise *promise) {
        [promise rejectPromise];
    }];

    // Check that we can read it twice without timeing out
    NSValue *val = [promise doneSynchronousWithTimeout:2000];
    XCTAssertNil(val);

}

- (void)testTimeout {
    // Should create the promise and run the block, which
    // never fulfills so promise will have to time out
    MAVEPromise *promise = [[MAVEPromise alloc] initWithBlock:^(MAVEPromise *promise) {
    }];

    // check time interval to be sure we actually blocked
    NSDate *preTimeoutDate = [NSDate date];
    NSValue *val = [promise doneSynchronousWithTimeout:0.01];
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:preTimeoutDate];
    XCTAssertGreaterThanOrEqual(elapsed, 0.01);
    XCTAssertEqualObjects(val, nil);
}

- (void)testDoneAsync {
    // Should create the promise and run the block
    NSValue *returnValue = (NSValue *)@"fooasdf";
    MAVEPromise *promise = [[MAVEPromise alloc] initWithBlock:^(MAVEPromise *promise) {
        [promise fulfillPromise:returnValue];
    }];

    // Check that we can read it twice without timeing out

    __block NSValue *val;
    [promise done:^(NSValue *result) {
        val = result;
        XCTAssertEqualObjects(val, returnValue);
    } withTimeout:0.01];
}

@end
