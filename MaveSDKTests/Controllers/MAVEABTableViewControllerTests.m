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

- (void)testSearchingFlags {
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc]
                                     initTableViewWithParent:ipvc];

    [vc searchBarShouldBeginEditing:vc.inviteTableHeaderView.searchBar];
    XCTAssertFalse(vc.searchBar.hidden);
    XCTAssertTrue(vc.inviteTableHeaderView.searchBar.hidden);
    XCTAssertTrue(vc.isSearching);
//    XCTAssertTrue(vc.searchBar.isFirstResponder); // firstResponder chain doesn't complete during tests
    XCTAssertFalse(vc.inviteTableHeaderView.searchBar.isFirstResponder);

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

@end
