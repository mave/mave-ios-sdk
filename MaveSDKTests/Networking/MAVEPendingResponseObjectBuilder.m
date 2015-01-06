//
//  MAVEHTTPRequestObjectBuilderTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/29/14.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEPendingResponseObjectBuilder.h"

@interface MAVEPendingResponseObjectBuilderDemo : NSObject<MAVEDictionaryInitializable>

@property NSDictionary *dataPassedIn;

@end

@implementation MAVEPendingResponseObjectBuilderDemo

- (instancetype) initWithDictionary:(NSDictionary *)data {
    if ([[data objectForKey:@"a"] isEqualToString:@"bad"]) {
        return nil;
    }
    if (self = [self init]) {
        self.dataPassedIn = data;
    }
    return self;
}

@end





@interface MAVEHTTPRequestObjectBuilderTests : XCTestCase

@end

@implementation MAVEHTTPRequestObjectBuilderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitBuilder {
    MAVEPendingResponseData *pendingData =
        [[MAVEPendingResponseData alloc] initWithDefaultData:@{@"foo": @"bar"}];
    MAVEPendingResponseObjectBuilder *builder =
        [[MAVEPendingResponseObjectBuilder alloc]
         initWithClass:[MAVEPendingResponseObjectBuilderDemo class] pendingResponseData:pendingData];
    XCTAssertEqual(builder.initializableClass, [MAVEPendingResponseObjectBuilderDemo class]);
    XCTAssertEqualObjects(builder.pendingResponseData, pendingData);
}

- (void)testBuilderInitObjectUsesResponseDataFirst {
    // set up mock
    NSDictionary *defaultData = @{@"a": @"a"};
    NSDictionary *responseData = @{@"a": @"b"};
    id mockedPendingData = [OCMockObject mockForClass:[MAVEPendingResponseData class]];
    [[mockedPendingData expect] readDataWithTimeout:2 completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^blockToCall)(NSDictionary *responseData, NSDictionary *returnData) = obj;
        blockToCall(responseData, defaultData);
        return YES;
    }]];
    
    // init builder
    MAVEPendingResponseObjectBuilder *builder =
        [[MAVEPendingResponseObjectBuilder alloc]
         initWithClass:[MAVEPendingResponseObjectBuilderDemo class] pendingResponseData:mockedPendingData];
    
    // call builder initialized and mocked method should be called, which should init our demo object with
    // the response data.
    __block MAVEPendingResponseObjectBuilderDemo *returnedObject;
    [builder initializeObjectWithTimeout:2 completionBlock:^(id obj) {
        returnedObject = obj;
    }];
    [mockedPendingData verify];
    XCTAssertNotNil(returnedObject);
    XCTAssertEqualObjects(returnedObject.dataPassedIn, responseData);
}

- (void)testBuilderInitObjectFallsBackToDefaultDataIfInitFails {
    // set up mock
    NSDictionary *defaultData = @{@"a": @"a"};
    NSDictionary *responseData = @{@"a": @"bad"};
    id mockedPendingData = [OCMockObject mockForClass:[MAVEPendingResponseData class]];
    [[mockedPendingData expect] readDataWithTimeout:2 completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^blockToCall)(NSDictionary *responseData, NSDictionary *returnData) = obj;
        blockToCall(responseData, defaultData);
        return YES;
    }]];
    
    // init builder
    MAVEPendingResponseObjectBuilder *builder =
    [[MAVEPendingResponseObjectBuilder alloc]
     initWithClass:[MAVEPendingResponseObjectBuilderDemo class] pendingResponseData:mockedPendingData];
    
    // call builder initialized and mocked method should be called, which should init our demo object with
    // the response data.
    __block MAVEPendingResponseObjectBuilderDemo *returnedObject;
    [builder initializeObjectWithTimeout:2 completionBlock:^(id obj) {
        returnedObject = obj;
    }];
    [mockedPendingData verify];
    XCTAssertNotNil(returnedObject);
    XCTAssertEqualObjects(returnedObject.dataPassedIn, defaultData);
}

@end





