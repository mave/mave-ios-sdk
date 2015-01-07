//
//  MAVEShareTokenTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEShareToken.h"

@interface MAVEShareTokenTests : XCTestCase

@end

@implementation MAVEShareTokenTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultJSONData {
    XCTAssertEqualObjects([MAVEShareToken defaultJSONData], @{});
}

- (void)testInitFromDefaultJSONData {
    MAVEShareToken *shareToken = [[MAVEShareToken alloc]
                                  initWithDictionary:[MAVEShareToken defaultJSONData]];
    XCTAssertNotNil(shareToken);
    XCTAssertNil(shareToken.shareToken);
}

- (void)testRemoteBuilder {
    id mock = OCMClassMock([MAVERemoteConfigurator class]);

    OCMExpect([mock alloc]).andReturn(mock);
    OCMExpect([mock initWithClassToCreate:[MAVEShareToken class]
                            preFetchBlock:[OCMArg any]
               userDefaultsPersistanceKey:MAVEUserDefaultsKeyShareToken
                              defaultData:[MAVEShareToken defaultJSONData]
                   preferLocallySavedData:YES]).andReturn(mock);
    id returnedVal = [MAVEShareToken remoteBuilder];

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(returnedVal, mock);
    [mock stopMocking];
}

@end
