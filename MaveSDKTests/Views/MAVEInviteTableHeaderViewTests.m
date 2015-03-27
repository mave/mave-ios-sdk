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

- (void)testInitWithDelegate {
    MAVECustomSharePageViewController *delegate = [[MAVECustomSharePageViewController alloc] init];
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;
    MAVEInviteTableHeaderView *view = [[MAVEInviteTableHeaderView alloc] initWithShareDelegate:delegate];
    view.showsShareButtons = YES;

    // Invite explanation view is present b/c copy is set
    XCTAssertGreaterThan([[MaveSDK sharedInstance].inviteExplanationCopy length], 0);
    XCTAssertTrue(view.showsExplanation);
    XCTAssertTrue([view.inviteExplanationView isDescendantOfView:view]);
    XCTAssertFalse(view.inviteExplanationView.hidden);

    XCTAssertEqualObjects(view.shareDelegate, delegate);
    XCTAssertEqualObjects(view.shareButtonsView.delegate, delegate);
    XCTAssertTrue([view.shareButtonsView isDescendantOfView:view]);

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
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
    remoteConfig.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] init];
    remoteConfig.contactsInvitePage.shareButtonsEnabled = YES;
    OCMExpect([maveMock remoteConfiguration]).andReturn(remoteConfig);

    MAVEInviteTableHeaderView *view = [[MAVEInviteTableHeaderView alloc] init];
    XCTAssertTrue([view hasContentOtherThanSearchBar]);
    OCMVerifyAll(maveMock);
}

- (void)testHasNoContentToShow {
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock inviteExplanationCopy]).andReturn(nil);
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
    remoteConfig.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] init];
    remoteConfig.contactsInvitePage.shareButtonsEnabled = NO;
    OCMExpect([maveMock remoteConfiguration]).andReturn(remoteConfig);

    MAVEInviteTableHeaderView *view = [[MAVEInviteTableHeaderView alloc] init];
    XCTAssertFalse([view hasContentOtherThanSearchBar]);
    OCMVerifyAll(maveMock);
}

@end
