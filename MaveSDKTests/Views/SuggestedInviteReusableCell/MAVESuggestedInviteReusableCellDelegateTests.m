//
//  MAVESuggestedInviteReusableCellDelegateTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/6/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVESuggestedInviteReusableCellDelegate.h"

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

- (void)testContactAtIndexPath {
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.recordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1;
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
}

- (void)testNumberOfRows {
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.recordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1;
    NSInteger section = 4; NSInteger numRows = 3;
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:nil sectionNumber:section maxNumberOfRows:numRows];
    del.liveData = @[p0, p1];
    XCTAssertEqual([del numberOfRows], 2);
}

- (void)testCellHeight {
    MAVESuggestedInviteReusableTableViewCell *tmpCell = [[MAVESuggestedInviteReusableTableViewCell alloc] init];
    NSInteger section = 4; NSInteger numRows = 3;
    MAVESuggestedInviteReusableCellDelegate *del = [[MAVESuggestedInviteReusableCellDelegate alloc] initForTableView:nil sectionNumber:section maxNumberOfRows:numRows];
    XCTAssertEqual([tmpCell cellHeight], 92);
    XCTAssertEqual([del cellHeight], [tmpCell cellHeight]);
}


@end
