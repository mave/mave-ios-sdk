//
//  MAVEInviteTableHeaderViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/22/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEInviteTableHeaderView.h"
#import "MaveSDK.h"
#import "MaveSDK_Internal.h"
#import "MAVEDisplayOptionsFactory.h"

@interface MAVEInviteTableHeaderViewTests : XCTestCase

@end

@implementation MAVEInviteTableHeaderViewTests

- (void)setUp {
    [super setUp];
    [MaveSDK sharedInstance].displayOptions = [MAVEDisplayOptionsFactory generateDisplayOptions];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;
    MAVEInviteTableHeaderView *view = [[MAVEInviteTableHeaderView alloc] init];

    // Invite explanation view is present b/c copy is set
    XCTAssertGreaterThan([[MaveSDK sharedInstance].inviteExplanationCopy length], 0);
    XCTAssertTrue(view.showsExplanation);
    XCTAssertTrue([view.inviteExplanationView isDescendantOfView:view]);
    XCTAssertFalse(view.inviteExplanationView.hidden);

    // Search bar top border
    XCTAssertEqual(view.searchBarTopBorder.frame.size.height, 1);
    XCTAssertEqualObjects(view.searchBarTopBorder.backgroundColor, opts.searchBarTopBorderColor);

    // Search bar
    XCTAssertTrue([view.searchBar isDescendantOfView:view]);
    XCTAssertEqual(view.searchBar.frame.size.height, MAVESearchBarHeight);
}

- (void)testHasContentToShow {
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock inviteExplanationCopy]).andReturn(@"Copy Override");

    MAVEInviteTableHeaderView *view = [[MAVEInviteTableHeaderView alloc] init];
    XCTAssertTrue([view hasContentToShow]);
    OCMVerifyAll(maveMock);
}

- (void)testHasNoContentToShow {
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock inviteExplanationCopy]).andReturn(nil);

    MAVEInviteTableHeaderView *view = [[MAVEInviteTableHeaderView alloc] init];
    XCTAssertFalse([view hasContentToShow]);
    OCMVerifyAll(maveMock);
}

@end
