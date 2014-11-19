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
    id mockedIPVC = [OCMockObject mockForClass:[MAVEInvitePageViewController class]];
    id mockedTableView = [OCMockObject mockForClass:[UITableView class]];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] initTableViewWithParent:mockedIPVC];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234"]; p1.selected = NO;
    [vc updateTableData:@{@"A": @[p1]}];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    [[mockedIPVC expect] ABTableViewControllerNumberSelectedChanged:1];
    [[mockedTableView expect] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    // Run
    [vc tableView:nil didSelectRowAtIndexPath:indexPath];
    
    // Verify
    XCTAssertEqualObjects(vc.selectedPhoneNumbers, [NSSet setWithArray:@[@"18085551234"]]);
    [mockedIPVC verify];
}

- (void)testClickDidSelectRowAtIndexPathAddsBestNumberToSelectedPhoneNumbers {
    // selecting the row should add the person's bestNumber to selectedPhoneNumbers

    // Set up data
    id mockedIPVC = [OCMockObject mockForClass:[MAVEInvitePageViewController class]];
    id mockedTableView = [OCMockObject mockForClass:[UITableView class]];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] initTableViewWithParent:mockedIPVC];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234", @"12125551234"]; p1.selected = NO;
    p1.phoneNumberLabels = @[@"_$!<Main>!$_", @"_$!<Mobile>!$_"];
    [vc updateTableData:@{@"A": @[p1]}];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    [[mockedIPVC expect] ABTableViewControllerNumberSelectedChanged:1];
    [[mockedTableView expect] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    // Run
    [vc tableView:nil didSelectRowAtIndexPath:indexPath];
    
    // Verify the <Mobile> number was selected
    XCTAssertEqualObjects(vc.selectedPhoneNumbers, [NSSet setWithArray:@[@"12125551234"]]);
    [mockedIPVC verify];
}

- (void)testClickDidSelectRowAtIndexPathRemovesBestNumberToSelectedPhoneNumbers {
    // deselecting the row should remove the person's bestNumber from selectedPhoneNumbers

    // Set up data
    id mockedIPVC = [OCMockObject mockForClass:[MAVEInvitePageViewController class]];
    id mockedTableView = [OCMockObject mockForClass:[UITableView class]];
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] initTableViewWithParent:mockedIPVC];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Abbie"; p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"18085551234", @"12125551234"]; p1.selected = NO;
    p1.phoneNumberLabels = @[@"_$!<Main>!$_", @"_$!<Mobile>!$_"];
    [vc updateTableData:@{@"A": @[p1]}];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    [[mockedIPVC expect] ABTableViewControllerNumberSelectedChanged:1];
    [[mockedTableView expect] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    // Select, then deselect
    [vc tableView:nil didSelectRowAtIndexPath:indexPath];
    
    [[mockedIPVC expect] ABTableViewControllerNumberSelectedChanged:0];
    [vc tableView:nil didSelectRowAtIndexPath:indexPath];
    
    // Verify
    XCTAssertEqual([vc.selectedPhoneNumbers count], 0);
    [mockedIPVC verify];
}

@end
