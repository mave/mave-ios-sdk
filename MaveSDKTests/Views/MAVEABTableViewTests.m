//
//  MAVEABPersonCellTests.m
//  MaveSDK
//
//  Created by dannycosson on 10/20/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVEDisplayOptions.h"
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEABTableViewController.h"
#import "MAVEABPersonCell.h"

@interface MAVEABTableViewTests : XCTestCase

@end

@implementation MAVEABTableViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    [MaveSDK sharedInstance].displayOptions = [MAVEDisplayOptionsFactory generateDisplayOptions];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTableStyle {
    MAVEABPerson *person = [[MAVEABPerson alloc] init];
    person.firstName = @"Danny";
    NSDictionary *data = @{@"D": @[person]};
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] initTableViewWithParent:nil];
    [vc updateTableData:data];
    XCTAssertNotNil(vc.tableView);
    XCTAssertNotNil(vc.aboveTableContentView);
    
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
    XCTAssertEqualObjects(vc.tableView.backgroundColor, displayOptions.contactCellBackgroundColor);
    XCTAssertEqualObjects(vc.aboveTableContentView.backgroundColor, displayOptions.contactCellBackgroundColor);
    XCTAssertEqualObjects(vc.tableView.sectionIndexColor, displayOptions.contactSectionIndexColor);
    XCTAssertEqualObjects(vc.tableView.sectionIndexBackgroundColor, displayOptions.contactSectionIndexBackgroundColor);
    XCTAssertEqualObjects(vc.tableView.separatorColor, displayOptions.contactSeparatorColor);
}

- (void)testPersonCellStyleOnInit {
    // This is the init method called by the table view's dequeue method
    MAVEABPersonCell *cell = [[MAVEABPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Foo"];
    XCTAssertNotNil(cell);

    MAVEDisplayOptions *displayOpts = [MaveSDK sharedInstance].displayOptions;

    XCTAssertEqual(cell.selectionStyle, UITableViewCellSelectionStyleNone);
    XCTAssertEqualObjects(cell.textLabel.font, displayOpts.contactNameFont);
    XCTAssertEqualObjects(cell.textLabel.textColor, displayOpts.contactNameTextColor);
    XCTAssertEqualObjects(cell.detailTextLabel.font, displayOpts.contactDetailsFont);
    XCTAssertEqualObjects(cell.detailTextLabel.textColor, displayOpts.contactDetailsTextColor);
    XCTAssertEqualObjects(cell.backgroundColor, displayOpts.contactCellBackgroundColor);
    XCTAssertEqualObjects(cell.tintColor, displayOpts.contactCheckmarkColor);
}

- (void)testTableSectionHeader {
    NSDictionary *data = @{@"D": @[[[MAVEABPerson alloc] init]]};
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] initTableViewWithParent:nil];
    [vc updateTableData:data];

    UIView *sectionHeaderView = [vc tableView:vc.tableView viewForHeaderInSection:0];
    XCTAssertTrue([sectionHeaderView isKindOfClass:[MAVEInviteTableSectionHeaderView class]]);
    NSString *titleText = ((MAVEInviteTableSectionHeaderView *)sectionHeaderView).titleLabel.text;
    XCTAssertEqualObjects(titleText, @"D");
}


- (void)testUpdateTableDataAnimatedWithSuggestedInvites {
    // Set up existing state
    MAVEABPerson *fakePerson = [[MAVEABPerson alloc] init];
    NSDictionary *oldData = @{@"D": @[fakePerson]};
    MAVEABTableViewController *tableVC = [[MAVEABTableViewController alloc] init];
    id mockTable = OCMClassMock([UITableView class]);
    id suggestedSectionHeader = OCMClassMock([MAVEInviteTableSectionHeaderView class]);
    tableVC.tableView = mockTable;
    tableVC.suggestedInvitesSectionHeaderView = suggestedSectionHeader;
    [tableVC updateTableData:oldData];

    // Set up expectation
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.firstName = @"Paul";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p1.firstName = @"John";
    NSArray *suggestedInvites = @[p1, p2];
    NSDictionary *expectedData = @{@"★": suggestedInvites,
                                   @"D": @[fakePerson]};
    NSArray *expectedSections = @[@"★", @"D"];
    OCMExpect([[mockTable ignoringNonObjectArgs] insertRowsAtIndexPaths:[OCMArg any] withRowAnimation:0]);
    OCMExpect([suggestedSectionHeader stopWaiting]);

    [tableVC updateTableDataAnimatedWithSuggestedInvites:suggestedInvites];

    XCTAssertEqualObjects(tableVC.tableData, expectedData);
    XCTAssertEqualObjects(tableVC.tableSections, expectedSections);
    OCMVerifyAll(mockTable);
    OCMVerifyAll(suggestedSectionHeader);
}

- (void)testUpdateTableDataAnimatedWithSuggestedWhenTableHasEmptySuggestedAlready {
    // Set up existing state
    MAVEABPerson *fakePerson = [[MAVEABPerson alloc] init];
    NSDictionary *oldData = @{@"★": @[], @"D": @[fakePerson]};
    MAVEABTableViewController *tableVC = [[MAVEABTableViewController alloc] init];
    [tableVC updateTableData:oldData];

    // Set up expectation
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.firstName = @"Paul";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p1.firstName = @"John";
    NSArray *suggestedInvites = @[p1, p2];
    NSDictionary *expectedData = @{@"★": suggestedInvites,
                                   @"D": @[fakePerson]};
    NSArray *expectedSections = @[@"★", @"D"];

    [tableVC updateTableDataAnimatedWithSuggestedInvites:suggestedInvites];

    XCTAssertEqualObjects(tableVC.tableData, expectedData);
    XCTAssertEqualObjects(tableVC.tableSections, expectedSections);
}

- (void)testUpdateTableDataAnimatedWithNoSuggestedInvites {
    // Set up existing state
    MAVEABPerson *fakePerson = [[MAVEABPerson alloc] init];
    // the old data might already have the suggested section but it's empty
    NSDictionary *oldData = @{@"D": @[fakePerson]};
    MAVEABTableViewController *tableVC = [[MAVEABTableViewController alloc] init];
    id mockTable = OCMClassMock([UITableView class]);
    id suggestedSectionHeader = OCMClassMock([MAVEInviteTableSectionHeaderView class]);
    tableVC.tableView = mockTable;
    tableVC.suggestedInvitesSectionHeaderView = suggestedSectionHeader;
    [tableVC updateTableData:oldData];

    // Set up expectation
    NSArray *suggestedInvites = @[];
    NSDictionary *expectedData = @{@"D": @[fakePerson]};
    NSArray *expectedSections = @[@"D"];
    [[[mockTable reject] ignoringNonObjectArgs] insertRowsAtIndexPaths:[OCMArg any] withRowAnimation:0];
    [[suggestedSectionHeader reject] stopWaiting];

    [tableVC updateTableDataAnimatedWithSuggestedInvites:suggestedInvites];

    XCTAssertEqualObjects(tableVC.tableData, expectedData);
    XCTAssertEqualObjects(tableVC.tableSections, expectedSections);
    OCMVerifyAll(mockTable);
    OCMVerifyAll(suggestedSectionHeader);
}

- (void)testUpdateTableDataAnimatedWithNoSuggestedInvitesWhenTableHasEmptySuggestedAlready {
    // Should delete the empty suggested category that already exists
    // Set up existing state
    MAVEABPerson *fakePerson = [[MAVEABPerson alloc] init];
    NSDictionary *oldData = @{@"★": @[], @"D": @[fakePerson]};
    MAVEABTableViewController *tableVC = [[MAVEABTableViewController alloc] init];
    [tableVC updateTableData:oldData];

    // Set up expectation
    NSArray *suggestedInvites = @[];
    NSDictionary *expectedData = @{@"D": @[fakePerson]};
    NSArray *expectedSections = @[@"D"];

    [tableVC updateTableDataAnimatedWithSuggestedInvites:suggestedInvites];

    XCTAssertEqualObjects(tableVC.tableData, expectedData);
    XCTAssertEqualObjects(tableVC.tableSections, expectedSections);
}

@end
