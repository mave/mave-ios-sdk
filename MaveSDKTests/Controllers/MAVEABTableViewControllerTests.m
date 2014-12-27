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
    // can't mock ipvc because it gets set in the
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

@end
