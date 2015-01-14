//
//  MAVEShareTokenTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEConstants.h"
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
    NSDictionary *defaults = [MAVEShareToken defaultJSONData];
    XCTAssertEqualObjects([defaults objectForKey:@"share_token"], @"");
}

- (void)testInitFromDefaultJSONData {
    MAVEShareToken *shareToken = [[MAVEShareToken alloc]
                                  initWithDictionary:[MAVEShareToken defaultJSONData]];
    XCTAssertNotNil(shareToken);
    XCTAssertEqualObjects(shareToken.shareToken, @"");
}

- (void)testInitWithNoShareTokenReturnsNil {
    MAVEShareToken *shareToken = [[MAVEShareToken alloc] initWithDictionary:@{}];
    XCTAssertNil(shareToken);
}

- (void)testRemoteBuilder {
    id mock = OCMClassMock([MAVERemoteObjectBuilder class]);

    OCMExpect([mock alloc]).andReturn(mock);
    OCMExpect([mock initWithClassToCreate:[MAVEShareToken class]
                            preFetchBlock:[OCMArg any]
                              defaultData:[MAVEShareToken defaultJSONData]
        saveIfSuccessfulToUserDefaultsKey:MAVEUserDefaultsKeyShareToken
                   preferLocallySavedData:YES]).andReturn(mock);

    id returnedVal = [MAVEShareToken remoteBuilder];

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(returnedVal, mock);
    [mock stopMocking];
}

- (void)testUserDefaultsKey {
    // in testing mode it should have TESTS in the name
    XCTAssertEqualObjects(MAVEAPIBaseURL, @"test-api-mave-io/");
    XCTAssertEqualObjects(MAVEUserDefaultsKeyShareToken, @"MAVETESTSUserDefaultsKeyShareToken");
}

- (void)testClearUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"foo" forKey:MAVEUserDefaultsKeyShareToken];

    XCTAssertEqualObjects([defaults objectForKey:MAVEUserDefaultsKeyShareToken], @"foo");
    XCTAssertEqualObjects([defaults objectForKey:MAVEUserDefaultsKeyShareToken], @"foo");

    [MAVEShareToken clearUserDefaults];
    XCTAssertNil([defaults objectForKey:MAVEUserDefaultsKeyShareToken]);
}

@end
