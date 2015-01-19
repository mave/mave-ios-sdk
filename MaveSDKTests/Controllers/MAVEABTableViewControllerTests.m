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
#import "MAVEABTestDataFactory.h"

@interface MAVEABTableViewControllerTests : XCTestCase

@end

@implementation MAVEABTableViewControllerTests

/*
 * Note, unable to use this mock when initializing an instance of MAVEABTableVC:
 *     id mockedIPVC = [OCMockObject mockForClass:[MAVEInvitePageViewController class]];
 *
 * When the searchDisplayController is created, UIKit requires an instance of a
 * UIViewController, a mock is not sufficient. Instead, set the mock on
 * MAVEABTableVC later in the test.
 */

- (void)setUp {
    [super setUp];
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

- (void)testClickDidSelectRowAtIndexPath {
    // selecting the row should toggle the corresponding person's selected attribute and call
    // a method on the parent to inform of the update

    // Set up data
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    id mockedTableView = [OCMockObject mockForClass:[UITableView class]];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234"]; p1.selected = NO;
    [vc updateTableData:@{@"A": @[p1]}];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    id mockedIPVC = [OCMockObject mockForClass:[MAVEInvitePageViewController class]];
    vc.parentViewController = mockedIPVC;
    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    [[mockedIPVC expect] ABTableViewControllerNumberSelectedChanged:1];
    [[mockedTableView expect] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    // Run
    [vc tableView:vc.tableView didSelectRowAtIndexPath:indexPath];
    
    // Verify
    XCTAssertEqualObjects(vc.selectedPhoneNumbers, [NSSet setWithArray:@[@"18085551234"]]);
    [mockedIPVC verify];
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
    XCTAssertEqual([expectedAllPersons count], [[vc allPersons] count]);
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

- (void)testSearchBarsDuringScroll {
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];
    [self populateTableDataForABTableVC:vc];

    // Starts at top, no scrolling yet
    XCTAssertFalse(vc.inviteTableHeaderView.searchBar.hidden);
    XCTAssertTrue(vc.searchBar.hidden);

    // Scroll to somewhere midway down
    [vc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:9]
                        atScrollPosition:UITableViewScrollPositionTop animated:NO];
    XCTAssertTrue(vc.inviteTableHeaderView.searchBar.hidden);
    XCTAssertFalse(vc.searchBar.hidden);

    // Back to top
    [vc.tableView setContentOffset:CGPointMake(0, -100) animated:NO];
    [vc scrollViewDidScroll:vc.tableView]; // force call, which isn't happening in the above line
    XCTAssertFalse(vc.inviteTableHeaderView.searchBar.hidden);
    XCTAssertTrue(vc.searchBar.hidden);
}

- (void)testSearchingFlags {
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];

    [vc textFieldShouldBeginEditing:vc.inviteTableHeaderView.searchBar];
    XCTAssertFalse(vc.searchBar.hidden);
    XCTAssertTrue(vc.inviteTableHeaderView.searchBar.hidden);
    XCTAssertTrue(vc.isSearching);
//    XCTAssertTrue(vc.searchBar.isFirstResponder); // firstResponder chain doesn't complete during tests
    XCTAssertFalse(vc.inviteTableHeaderView.searchBar.isFirstResponder);
    [vc searchBarShouldBeginEditing:vc.searchBar];

    [vc searchBarTextDidEndEditing:vc.searchBar];
    XCTAssertFalse(vc.searchBar.hidden);
    XCTAssertTrue(vc.inviteTableHeaderView.searchBar.hidden);
    XCTAssertFalse(vc.isSearching);
    XCTAssertFalse(vc.searchBar.isFirstResponder);
    XCTAssertFalse(vc.inviteTableHeaderView.searchBar.isFirstResponder);
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

    [vc searchBarShouldBeginEditing:vc.inviteTableHeaderView.searchBar];
    [vc searchBarShouldBeginEditing:vc.searchBar];
    XCTAssertNotEqual([UIColor clearColor], vc.tableView.sectionIndexColor);

    [vc searchBar:vc.searchBar textDidChange:@"a"];
    XCTAssertEqual([UIColor clearColor], vc.tableView.sectionIndexColor);
}

@end
