//
//  MAVESuggestedInviteReusableCellDelegateTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/6/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVESuggestedInviteReusableCellDelegate.h"
#import "MaveSDK.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVESuggestedInviteReusableCellDelegateTests : XCTestCase

@end

@implementation MAVESuggestedInviteReusableCellDelegateTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    UITableView *tv = [[UITableView alloc] init];
    NSInteger section = 4; NSInteger numRows = 5;
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:tv sectionNumber:section maxNumberOfRows:numRows];
    XCTAssertEqualObjects(del.tableView, tv);
    XCTAssertEqual(del.sectionNumber, section);
    XCTAssertEqual(del.maxNumberOfRows, numRows);
    XCTAssertEqualObjects(del.fullContactsPageInviteContext, @"InvitePageFromBottomOfReusableSuggestionsTable");
    XCTAssertEqualObjects(del.suggestionsCellInviteContext, @"ReusableSuggestionCell");
}

- (void)testLoadSuggestedInvitesWhenMoreThanNumberOfRows {
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.recordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.recordID = 2;
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init]; p3.recordID = 3;
    NSArray *suggestions = @[p0, p1, p2, p3];

    NSInteger section = 2; NSInteger numRows = 3;
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:nil sectionNumber:section maxNumberOfRows:numRows];

    [del _loadSuggestedInvites:suggestions];
    XCTAssertEqual([del.liveData count], 3);
    XCTAssertEqualObjects(del.liveData[0], p0);
    XCTAssertEqualObjects(del.liveData[1], p1);
    XCTAssertEqualObjects(del.liveData[2], p2);
    XCTAssertEqual([del.standbyData count], 1);
    XCTAssertEqualObjects(del.standbyData[0], p3);
}

- (void)testLoadSuggestedInvitesWhenLessThanNumberOfRows {
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.recordID = 0;
    NSArray *suggestions = @[p0];

    NSInteger section = 4; NSInteger numRows = 3;
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:nil sectionNumber:section maxNumberOfRows:numRows];

    [del _loadSuggestedInvites:suggestions];
    XCTAssertEqual([del.liveData count], 1);
    XCTAssertEqualObjects(del.liveData[0], p0);
    XCTAssertEqual([del.standbyData count], 0);
}

- (void)testContactAtIndexPathAndReverseIndex {
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.recordID = 10;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 11;
    NSInteger section = 4; NSInteger numRows = 3;
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:nil sectionNumber:section maxNumberOfRows:numRows];
    del.liveData = @[p0, p1];

    MAVEABPerson *queried0 = [del _contactAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
    XCTAssertEqualObjects(queried0, p0);
    MAVEABPerson *queried1 = [del _contactAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4]];
    XCTAssertEqualObjects(queried1, p1);
    MAVEABPerson *queried2 = [del _contactAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:4]];
    XCTAssertNil(queried2);
    MAVEABPerson *queried3 = [del _contactAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:4]];
    XCTAssertNil(queried3);
    MAVEABPerson *queried4 = [del _contactAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]];
    XCTAssertNil(queried4);

    XCTAssertEqual([del.recordIDToIndexMap count], 2);
    XCTAssertEqualObjects([del.recordIDToIndexMap objectForKey:@(10)], @(0));
    XCTAssertEqualObjects([del.recordIDToIndexMap objectForKey:@(10)], @(0));
}

- (void)testNumberOfRowsIncludesLastInvitePageButtonRow {
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.recordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1;
    NSInteger section = 4; NSInteger numRows = 6;
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:nil sectionNumber:section maxNumberOfRows:numRows];
    del.includeInviteFriendsCell = YES;
    [del _loadSuggestedInvites:@[p0, p1]];
    XCTAssertEqual([del numberOfRows], 3);
}

- (void)testCellHeight {
    MAVESuggestedInviteReusableTableViewCell *tmpCell = [[MAVESuggestedInviteReusableTableViewCell alloc] init];
    NSInteger section = 4; NSInteger numRows = 3;
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:nil sectionNumber:section maxNumberOfRows:numRows];
    XCTAssertEqual([tmpCell cellHeight], 62);
    XCTAssertEqual([del cellHeight], [tmpCell cellHeight]);
}

- (void)testSettingFullPageInviteContextSetsItOnTheInviteButton {
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:nil sectionNumber:0 maxNumberOfRows:2];
    del.fullContactsPageInviteContext = @"foo ad";
    XCTAssertEqualObjects(del.inviteFriendsCell.inviteFriendsButton.inviteContext, @"foo ad");
}

- (void)testSendInviteToContact {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstance];
    MAVEUserData *user = [[MAVEUserData alloc] init];
    user.userID = @"1234";
    [MaveSDK sharedInstance].userData = user;
    [MaveSDK sharedInstance].defaultSMSMessageText = @"foo mes";

    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.recordID = 10;
    MAVEContactPhoneNumber *phone0 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:@"Other"];
    phone0.selected = NO;
    MAVEContactEmail *email0 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    email0.selected = NO;
    p0.emailObjects = @[email0];
    p0.phoneObjects = @[phone0];
    NSInteger section = 4; NSInteger numRows = 3;
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:nil sectionNumber:section maxNumberOfRows:numRows];
    del.suggestionsCellInviteContext = @"Foo";
    del.fullContactsPageInviteContext = @"Bar";

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    NSArray *expectedRecipients = @[p0];
    OCMExpect([apiInterfaceMock sendInvitesToRecipients:expectedRecipients smsCopy:@"foo mes" senderUserID:@"1234" inviteLinkDestinationURL:user.inviteLinkDestinationURL wrapInviteLink:user.wrapInviteLink customData:user.customData completionBlock:[OCMArg any]]);

    [del sendInviteToContact:p0];

    OCMVerifyAll(apiInterfaceMock);
    XCTAssertTrue(p0.isSuggestedContact);
    XCTAssertTrue(p0.selectedFromSuggestions);
    XCTAssertTrue(p0.selected);
    XCTAssertTrue(phone0.selected);
    XCTAssertFalse(email0.selected);
    XCTAssertEqualObjects([MaveSDK sharedInstance].inviteContext, @"Foo");
}

- (void)testSetNumberContactsLabelText {
    MAVESuggestedInviteReusableTableViewCell *cell = [[MAVESuggestedInviteReusableTableViewCell alloc] init];

    [cell _setNumberContactsLabelText:0];
    XCTAssertEqualObjects(cell.subtitleLabel.text, @"0 friends on app");
    [cell _setNumberContactsLabelText:1];
    XCTAssertEqualObjects(cell.subtitleLabel.text, @"1 friend on app");
    [cell _setNumberContactsLabelText:9];
    XCTAssertEqualObjects(cell.subtitleLabel.text, @"9 friends on app");
}


@end
