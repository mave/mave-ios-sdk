//
//  GrowthKitTests.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GrowthKit.h"

@interface GrowthKitTests : XCTestCase

@end

@implementation GrowthKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetupAndGetSharedInstance{
    [GrowthKit setupSharedInstanceWithAppId:@"foo123"];
    GrowthKit *gk1 = [GrowthKit sharedInstance];
    GrowthKit *gk2 = [GrowthKit sharedInstance];
    
    // Test pointer to same object
    XCTAssertTrue(gk1 == gk2);
    XCTAssertEqualObjects(gk1.appId, @"foo123");
    XCTAssertEqualObjects(gk2.appId,@"foo123");
}

- (void)testSetUserData {
    [GrowthKit setupSharedInstanceWithAppId:@"foo123"];
    GrowthKit *gk = [GrowthKit sharedInstance];
    [gk setUserData:@"123" firstName:@"Foo" lastName:@"Jones"];
    
    XCTAssertEqualObjects(gk.currentUserId, @"123");
    XCTAssertEqualObjects(gk.currentUserFirstName, @"Foo");
    XCTAssertEqualObjects(gk.currentUserLastName, @"Jones");
}

@end