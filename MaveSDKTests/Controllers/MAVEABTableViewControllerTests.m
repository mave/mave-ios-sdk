//
//  MAVEABTableViewControllerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 10/23/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEInvitePageViewController.h"
#import "MAVEABTableViewController.h"
#import "MAVEABPerson.h"
#import "MaveSDK.h"
#import "MAVEABTestDataFactory.h"
#import "MAVEDisplayOptionsFactory.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEABTableViewControllerTests : XCTestCase

@end

@implementation MAVEABTableViewControllerTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"1231234"];
    [MaveSDK sharedInstance].userData = [[MAVEUserData alloc] init];
    [MaveSDK sharedInstance].userData.userID = @"foo";
    [MaveSDK sharedInstance].displayOptions =
    [MAVEDisplayOptionsFactory generateDisplayOptions];
    [MaveSDK sharedInstance].defaultSMSMessageText = @"dfeault text";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSArray *)populateTableDataForABTableVC:(MAVEABTableViewController *)vc {
    MAVEABPerson *p1  = [MAVEABTestDataFactory personWithFirstName:@"Abbie" lastName:@"Foo"];
    MAVEABPerson *p2  = [MAVEABTestDataFactory personWithFirstName:@"Bbbie" lastName:@"Foo"];
    MAVEABPerson *p3  = [MAVEABTestDataFactory personWithFirstName:@"Cbbie" lastName:@"Foo"];
    MAVEABPerson *p4  = [MAVEABTestDataFactory personWithFirstName:@"Dbbie" lastName:@"Foo"];
    MAVEABPerson *p5  = [MAVEABTestDataFactory personWithFirstName:@"Ebbie" lastName:@"Foo"];
    MAVEABPerson *p6  = [MAVEABTestDataFactory personWithFirstName:@"Fbbie" lastName:@"Foo"];
    MAVEABPerson *p7  = [MAVEABTestDataFactory personWithFirstName:@"Gbbie" lastName:@"Foo"];
    MAVEABPerson *p8  = [MAVEABTestDataFactory personWithFirstName:@"Hbbie" lastName:@"Foo"];
    MAVEABPerson *p9  = [MAVEABTestDataFactory personWithFirstName:@"Ibbie" lastName:@"Foo"];
    MAVEABPerson *p10 = [MAVEABTestDataFactory personWithFirstName:@"Jbbie" lastName:@"Foo"];
    MAVEABPerson *p11 = [MAVEABTestDataFactory personWithFirstName:@"Kbbie" lastName:@"Foo"];
    MAVEABPerson *p12 = [MAVEABTestDataFactory personWithFirstName:@"Lbbie" lastName:@"Foo"];
    MAVEABPerson *p13 = [MAVEABTestDataFactory personWithFirstName:@"Mbbie" lastName:@"Foo"];
    MAVEABPerson *p14 = [MAVEABTestDataFactory personWithFirstName:@"Nbbie" lastName:@"Foo"];
    MAVEABPerson *p15 = [MAVEABTestDataFactory personWithFirstName:@"Obbie" lastName:@"Foo"];
    MAVEABPerson *p16 = [MAVEABTestDataFactory personWithFirstName:@"Ozzzz" lastName:@"Fzz"];

    [vc updateTableData:@{@"a": @[p1],
                          @"b": @[p2],
                          @"c": @[p3],
                          @"d": @[p4],
                          @"e": @[p5],
                          @"f": @[p6],
                          @"g": @[p7],
                          @"h": @[p8],
                          @"i": @[p9],
                          @"j": @[p10],
                          @"k": @[p11],
                          @"l": @[p12],
                          @"m": @[p13],
                          @"n": @[p14],
                          @"o": @[p15, p16]}];

    return @[p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16];
}

- (void)testUpdateTableData {
    // check that it copies data and the appropriate transformations
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] init];
    NSArray *peopleArray = [self populateTableDataForABTableVC:vc];
    NSArray *expectedIndexes = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o"];
    MAVEABPerson *lastPerson = [peopleArray objectAtIndex:[peopleArray count]-1];
    NSInteger numPeople = [peopleArray count];
    NSInteger numSections = [expectedIndexes count];
    XCTAssertEqual(numPeople, 16);
    XCTAssertEqual(numSections, 15);

    XCTAssertEqual([vc.tableData count], numSections);
    XCTAssertEqualObjects(vc.tableSections, expectedIndexes);

    XCTAssertEqual([vc.personToIndexPathsIndex count], numPeople);
    XCTAssertEqualObjects([vc indexPathsOnMainTableViewForPerson:lastPerson],
                          @[[NSIndexPath indexPathForRow:1 inSection:14]]);
}

// Build the reverse index mapping a person to the list of index paths where that person
// occurs in the table
- (void)testUpdatePersonToIndexPathsIndexAndQueryForPaths {
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] init];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.recordID = 2;
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init]; p3.recordID = 3;
    MAVEABPerson *p4 = [[MAVEABPerson alloc] init]; p4.recordID = 4;
    vc.tableSections = @[@"★", @"B", @"#"];
    // Notice there's a duplicate, p0 occurs in multiple sections.
    // This would happen with, say, suggested invites
    vc.tableData = @{@"★": @[p1], @"B": @[p2, p3], @"#": @[p4, p1]};

    // build the index and ensure it looks how we expect
    [vc updatePersonToIndexPathsIndex];
    NSDictionary *expectedIndex = @{
        @(p1.recordID): @[[NSIndexPath indexPathForRow:0 inSection:0],
                          [NSIndexPath indexPathForRow:1 inSection:2],
                          ],
        @(p2.recordID): @[[NSIndexPath indexPathForRow:0 inSection:1]],
        @(p3.recordID): @[[NSIndexPath indexPathForRow:1 inSection:1]],
        @(p4.recordID): @[[NSIndexPath indexPathForRow:0 inSection:2]],
    };
    XCTAssertEqualObjects(vc.personToIndexPathsIndex, expectedIndex);

    // then query the index and ensure we get back data we expect
    NSArray *expectedPaths1 = @[[NSIndexPath indexPathForRow:0 inSection:0],
                               [NSIndexPath indexPathForRow:1 inSection:2]];
    XCTAssertEqualObjects([vc indexPathsOnMainTableViewForPerson:p1], expectedPaths1);
    NSArray *expectedPaths2 = @[[NSIndexPath indexPathForRow:0 inSection:1]];
    XCTAssertEqualObjects([vc indexPathsOnMainTableViewForPerson:p2], expectedPaths2);

    // person not in table should just return 0 index path
    MAVEABPerson *p5 = [[MAVEABPerson alloc] init]; p5.recordID = 5;
    NSArray *expectedPaths5 = @[[NSIndexPath indexPathForRow:0 inSection:0]];
    XCTAssertEqualObjects([vc indexPathsOnMainTableViewForPerson:p5], expectedPaths5);
}

- (void)testIndexPathsOnMainTableWhenBadData {
    NSArray *fallbackIndexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0]];
    // no record ID
    MAVEABPerson *p1  = [[MAVEABPerson alloc] init];
    XCTAssertEqual(p1.recordID, 0);
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] init];
    [vc updateTableData:@{@"a": @[p1]}];
    XCTAssertEqualObjects([vc indexPathsOnMainTableViewForPerson:p1],
                          fallbackIndexPaths);

    // person not in table
    MAVEABPerson *p2  = [MAVEABTestDataFactory personWithFirstName:@"Bbbie" lastName:@"Foo"];
    XCTAssertGreaterThan(p2.recordID, 0);
    [vc updateTableData:@{}];
    XCTAssertEqualObjects([vc indexPathsOnMainTableViewForPerson:p2],
                          fallbackIndexPaths);

    // Index somehow messed up so we get an array of length 0. This case should use the
    // fallback path instead. We shouldn't get into this case, but test for it just in case,
    // want to be robust against crashing when we try to get object at index 0
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init]; p3.recordID = 3;
    vc.personToIndexPathsIndex = @{@(p3.recordID): @[]};
    XCTAssertEqualObjects([vc indexPathsOnMainTableViewForPerson:p3],
                          fallbackIndexPaths);
}

- (void)testAllPersons {
    // can't mock ipvc because it gets set in the init
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234"]; p1.selected = NO;

    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"John"; p2.lastName = @"Graham";
    p2.phoneNumbers = @[@"18085551235"]; p2.selected = NO;

    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.firstName = @"John"; p3.lastName = @"Smith";
    p3.phoneNumbers = @[@"18085551236"]; p3.selected = NO;

    MAVEABPerson *p4 = [[MAVEABPerson alloc] init];
    p4.firstName = @"Danny"; p4.lastName = @"Cosson";
    p4.phoneNumbers = @[@"18085551237"]; p4.selected = NO;

    [vc updateTableData:@{@"a": @[p1],
                          @"j": @[p2, p3],
                          @"d": @[p4]}];

    NSArray *expectedAllPersons = @[p1, p2, p3, p4];
    XCTAssertEqualObjects([vc allPersons], expectedAllPersons);
}

- (void)testAllPersonsDeDuplicatesThem {
    // With e.g. suggested invites at the top, people can be duplicated in
    // the table. The list of all persons should de-dupe them.
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234"]; p1.selected = NO;

    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"John"; p2.lastName = @"Graham";
    p2.phoneNumbers = @[@"18085551235"]; p2.selected = NO;

    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.firstName = @"John"; p3.lastName = @"Smith";
    p3.phoneNumbers = @[@"18085551236"]; p3.selected = NO;

    [vc updateTableData:@{@"\u2605": @[p1, p3],
                          @"a": @[p1],
                          @"j": @[p2, p3]}];

    NSArray *expectedAllPersons = @[p1, p3, p2];
    XCTAssertEqualObjects([vc allPersons], expectedAllPersons);
}

- (void)testClickDidSelectRowAtIndexPath {
    // selecting the row should toggle the corresponding person's selected attribute and call
    // a method on the parent to inform of the update, and send the tracking call via api interface

    // Set up data
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];
    id mockedTableView = OCMPartialMock(vc.tableView);
    id mockAPIInterface = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    id mockedIPVC = OCMClassMock([MAVEInvitePageViewController class]);
    vc.parentViewController = mockedIPVC;

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234"]; p1.selected = NO;
    [vc updateTableData:@{@"A": @[p1]}];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    OCMExpect([mockedIPVC ABTableViewControllerNumberSelectedChanged:1]);
    OCMExpect([mockedTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone]);
    OCMExpect([mockAPIInterface trackInvitePageSelectedContactFromList:@"contacts"]);
    
    // Run
    [vc tableView:vc.tableView didSelectRowAtIndexPath:indexPath];
    
    // Verify
    XCTAssertEqualObjects(vc.selectedPhoneNumbers, [NSSet setWithArray:@[@"18085551234"]]);
    OCMVerifyAll(mockedTableView);
    OCMVerifyAll(mockedIPVC);
    OCMVerifyAll(mockAPIInterface);
}

- (void)testClickDidSelectRowAtIndexPathWithSearchTableView {
    // Set up data
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    ipvc.abTableFixedSearchbar = [[MAVESearchBar alloc] init];
    ipvc.view = [[UIView alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];
    vc.searchTableView = [[UITableView alloc] init];
    id mockedTableView = OCMPartialMock(vc.tableView);
    id mockAPIInterface = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    id mockedIPVC = OCMPartialMock(ipvc);
    vc.parentViewController = mockedIPVC;

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234"]; p1.selected = NO;
    [vc updateTableData:@{@"A": @[p1]}];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    OCMExpect([mockedIPVC ABTableViewControllerNumberSelectedChanged:1]);
    OCMExpect([mockedTableView scrollToRowAtIndexPath:[OCMArg any]
                                     atScrollPosition:UITableViewScrollPositionTop
                                             animated:NO]);
    OCMExpect([mockedTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone]);
    OCMExpect([mockAPIInterface trackInvitePageSelectedContactFromList:@"contacts_search"]);

    // Run
    ipvc.abTableFixedSearchbar.text = @"foo";
    [vc textFieldDidChange:ipvc.abTableFixedSearchbar];
    XCTAssertTrue([vc.searchTableView isDescendantOfView:ipvc.view]);
    [vc tableView:vc.searchTableView didSelectRowAtIndexPath:indexPath];

    // Verify
    XCTAssertEqualObjects(vc.selectedPhoneNumbers, [NSSet setWithArray:@[@"18085551234"]]);
    XCTAssertEqualObjects(ipvc.abTableFixedSearchbar.text, @""); // text gets reset after searching
    XCTAssertFalse([vc.searchTableView isDescendantOfView:vc.tableView]);
    OCMVerifyAll(mockedTableView);
    OCMVerifyAll(mockedIPVC);
    OCMVerifyAll(mockAPIInterface);
}

- (void)testClickDidSelectRowAtIndexPathAddsBestNumberToSelectedPhoneNumbers {
    // selecting the row should add the person's bestNumber to selectedPhoneNumbers

    // Set up data
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    id mockedTableView = [OCMockObject mockForClass:[UITableView class]];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] initTableViewWithParent:ipvc];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234", @"12125551234"]; p1.selected = NO;
    p1.phoneNumberLabels = @[@"_$!<Main>!$_", @"_$!<Mobile>!$_"];
    [vc updateTableData:@{@"A": @[p1]}];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    id mockedIPVC = [OCMockObject mockForClass:[MAVEInvitePageViewController class]];
    vc.parentViewController = mockedIPVC;

    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    [[mockedIPVC expect] ABTableViewControllerNumberSelectedChanged:1];
    [[mockedTableView expect] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    // Run
    [vc tableView:vc.tableView didSelectRowAtIndexPath:indexPath];
    
    // Verify the <Mobile> number was selected
    XCTAssertEqualObjects(vc.selectedPhoneNumbers, [NSSet setWithArray:@[@"12125551234"]]);
    [mockedIPVC verify];
}

- (void)testClickDidSelectRowAtIndexPathRemovesBestNumberToSelectedPhoneNumbers {
    // deselecting the row should remove the person's bestNumber from selectedPhoneNumbers

    // Set up data
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    id mockedTableView = [OCMockObject mockForClass:[UITableView class]];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234", @"12125551234"]; p1.selected = NO;
    p1.phoneNumberLabels = @[@"_$!<Main>!$_", @"_$!<Mobile>!$_"];
    [vc updateTableData:@{@"A": @[p1]}];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    id mockedIPVC = [OCMockObject mockForClass:[MAVEInvitePageViewController class]];
    vc.parentViewController = mockedIPVC;

    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    [[mockedIPVC expect] ABTableViewControllerNumberSelectedChanged:1];
    [[mockedTableView expect] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    // Select, then deselect
    [vc tableView:vc.tableView didSelectRowAtIndexPath:indexPath];
    
    [[mockedIPVC expect] ABTableViewControllerNumberSelectedChanged:0];
    [vc tableView:vc.tableView didSelectRowAtIndexPath:indexPath];
    
    // Verify
    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    [mockedIPVC verify];
}

- (void)testPersonOnTableViewAtIndexPath {
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];
    NSArray *addedABData = [self populateTableDataForABTableVC:vc];

    // Test personOnTableView for tableView works
    XCTAssertEqual(addedABData[0], [vc personOnTableView:vc.tableView
                                             atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
    XCTAssertEqual(addedABData[14], [vc personOnTableView:vc.tableView
                                             atIndexPath:[NSIndexPath indexPathForRow:0 inSection:14]]);
    XCTAssertEqual(addedABData[15], [vc personOnTableView:vc.tableView
                                              atIndexPath:[NSIndexPath indexPathForRow:1 inSection:14]]);

    // Test personOnTableView for searchTableView works
    [vc searchContacts:@"o"]; // Will return "Obbie Foo" and "Ozzzz Fzz"
    XCTAssertEqual(addedABData[14], [vc personOnTableView:vc.searchTableView
                                             atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
    XCTAssertEqual(addedABData[15], [vc personOnTableView:vc.searchTableView
                                             atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]);
}

- (void)testSwitchToFixedSearchBarAndBackDuringScroll {
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    ipvc.view = [[UIView alloc] init];
    ipvc.abTableFixedSearchbar = [[MAVESearchBar alloc] initWithSingletonSearchBarDisplayOptions];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];
    ipvc.ABTableViewController = vc;
    [self populateTableDataForABTableVC:vc];

    // Starts at top, no scrolling yet
    XCTAssertFalse(vc.isFixedSearchBarActive);
    XCTAssertEqual(ipvc.abTableFixedSearchbar.frame.size.height, 0);
    XCTAssertGreaterThan(vc.inviteTableHeaderView.searchBar.frame.size.height, 0);

    // Scroll to somewhere midway down
    [vc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:9]
                        atScrollPosition:UITableViewScrollPositionTop animated:NO];
    XCTAssertTrue(vc.isFixedSearchBarActive);
    XCTAssertGreaterThan(ipvc.abTableFixedSearchbar.frame.size.height, 0);
    // the header view search bar is out of frame so it doesn't need to get set to 0
    XCTAssertGreaterThan(vc.inviteTableHeaderView.searchBar.frame.size.height, 0);

    // Back to top
    [vc.tableView setContentOffset:CGPointMake(0, -100) animated:NO];
    [vc scrollViewDidScroll:vc.tableView]; // force call, which isn't happening in the above line
    XCTAssertFalse(vc.isFixedSearchBarActive);
    XCTAssertEqual(ipvc.abTableFixedSearchbar.frame.size.height, 0);
    XCTAssertGreaterThan(vc.inviteTableHeaderView.searchBar.frame.size.height, 0);
}

- (void)testSearchContacts {
    // can't mock ipvc because it gets set in the init
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo"; p1.phoneNumbers = @[@"18085551234"]; p1.selected = NO;

    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"John"; p2.lastName = @"Graham"; p2.phoneNumbers = @[@"18085551235"]; p2.selected = NO;

    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.firstName = @"John"; p3.lastName = @"Smith"; p3.phoneNumbers = @[@"18085551236"]; p3.selected = NO;

    MAVEABPerson *p4 = [[MAVEABPerson alloc] init];
    p4.firstName = @"Danny"; p4.lastName = @"Cosson"; p4.phoneNumbers = @[@"18085551237"]; p4.selected = NO;

    MAVEABPerson *p5 = [[MAVEABPerson alloc] init];
    p5.firstName = @"Josh"; p5.lastName = @"Smith"; p5.phoneNumbers = @[@"18085551236"]; p5.selected = NO;


    [vc updateTableData:@{@"a": @[p1],
                          @"j": @[p2, p3, p5],
                          @"d": @[p4]}];

    // Searching for "Ab" will return 1 result (Abbie Foo)
    [vc searchContacts:@"Ab"];
    XCTAssertEqual(1, vc.searchedTableData.count);
    XCTAssertEqual(p1, vc.searchedTableData[0]);

    // Searching for "Ab" will return 1 result (Abbie Foo)
    [vc searchContacts:@"Abbie "];
    XCTAssertEqual(1, vc.searchedTableData.count);
    XCTAssertEqual(p1, vc.searchedTableData[0]);

    // Searching for "Ab" will return 1 result (Abbie Foo)
    [vc searchContacts:@"Abbi F"];
    XCTAssertEqual(1, vc.searchedTableData.count);
    XCTAssertEqual(p1, vc.searchedTableData[0]);

    // Searching for "Ab" will return 1 result (Abbie Foo)
    [vc searchContacts:@"Abbie Foo "];
    XCTAssertEqual(1, vc.searchedTableData.count);
    XCTAssertEqual(p1, vc.searchedTableData[0]);

    // Searching for "Jo" will return 3 results (John Graham, John Smith, Josh Smith)
    [vc searchContacts:@"Jo"];
    XCTAssertEqual(3, vc.searchedTableData.count);
    XCTAssertEqual(p2, vc.searchedTableData[0]);
    XCTAssertEqual(p3, vc.searchedTableData[1]);
    XCTAssertEqual(p5, vc.searchedTableData[2]);

    // Searching for "J Sm" will return 2 results (John Smith, Josh Smith)
    [vc searchContacts:@"J Sm"];
    XCTAssertEqual(2, vc.searchedTableData.count);
    XCTAssertEqual(p3, vc.searchedTableData[0]);
    XCTAssertEqual(p5, vc.searchedTableData[1]);

    // Searching for "smi j" will return 2 results (John Smith, Josh Smith)
    [vc searchContacts:@"smi j"];
    XCTAssertEqual(2, vc.searchedTableData.count);
    XCTAssertEqual(p3, vc.searchedTableData[0]);
    XCTAssertEqual(p5, vc.searchedTableData[1]);

    // Searching for "Jos S" will return 1 results (Josh Smith)
    [vc searchContacts:@"Jos S"];
    XCTAssertEqual(1, vc.searchedTableData.count);
    XCTAssertEqual(p5, vc.searchedTableData[0]);

    // Searching for "Jos S n" will return 0 results ()
    [vc searchContacts:@"Jos S n"];
    XCTAssertEqual(0, vc.searchedTableData.count);

    // Searching for "zx" will return 0 results ()
    [vc searchContacts:@"zx"];
    XCTAssertEqual(0, vc.searchedTableData.count);
}

- (void)testSearchingIndexTitleBar {
    // For some reason, the index titles alphabet side scroll bar is shown above all other
    //  subviews. In order to "hide" it, set the sectionIndexColor to clear when the
    //  searchTableView is being shown.
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];

    [vc textFieldShouldBeginEditing:vc.inviteTableHeaderView.searchBar];
    [vc textFieldShouldBeginEditing:ipvc.abTableFixedSearchbar];
    XCTAssertNotEqual([UIColor clearColor], vc.tableView.sectionIndexColor);

    ipvc.abTableFixedSearchbar.text = @"a";  // it changed
    [vc textFieldDidChange:ipvc.abTableFixedSearchbar];
    XCTAssertEqual([UIColor clearColor], vc.tableView.sectionIndexColor);
}

@end
