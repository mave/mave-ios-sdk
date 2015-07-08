//
//  MAVEContactsInvitePageDataManagerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 7/8/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEContactsInvitePageDataManager.h"

@interface MAVEContactsInvitePageDataManagerTests : XCTestCase

@end

@implementation MAVEContactsInvitePageDataManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSortSectionKeys {
    NSArray *keys = @[@"Z", MAVENonAlphabetNamesTableDataKey, MAVESuggestedInvitesTableDataKey, @"A"];
    NSArray *expected = @[MAVESuggestedInvitesTableDataKey, @"A", @"Z", MAVENonAlphabetNamesTableDataKey];

    NSArray *output = [MAVEContactsInvitePageDataManager sortedSectionKeys:keys];
    XCTAssertEqualObjects(output, expected);
}

@end
