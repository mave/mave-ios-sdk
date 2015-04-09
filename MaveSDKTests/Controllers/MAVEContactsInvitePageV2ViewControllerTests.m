//
//  MAVEContactsInvitePageV2ViewControllerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEContactsInvitePageV2ViewController.h"

@interface MAVEContactsInvitePageV2ViewControllerTests : XCTestCase

@end

@implementation MAVEContactsInvitePageV2ViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetup {

}

- (void)testUpdateTableDataAndCountSectionsAndRows {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Ben";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"Bat";
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.firstName = @"Aaron";
    NSDictionary *data = @{@"B": @[p1, p2], @"A": @[p3]};
    XCTAssertEqual([vc numberOfSectionsInTableView:vc.tableView], 0);

    [vc updateTableData:data];

    XCTAssertEqualObjects(vc.tableData, data);
    NSArray *expectedSections = @[@"A", @"B"];
    XCTAssertEqualObjects(vc.tableSections, expectedSections);
    NSArray *expectedAllContacts = @[p3, p1, p2];
    XCTAssertEqualObjects(vc.allContacts, expectedAllContacts);

    XCTAssertEqual([vc numberOfSectionsInTableView:vc.tableView], 2);
    XCTAssertEqual([vc tableView:vc.tableView numberOfRowsInSection:0], 1);
    XCTAssertEqual([vc tableView:vc.tableView numberOfRowsInSection:1], 2);
}

- (void)testPersonAtIndexPath {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Ben";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"Bat";
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.firstName = @"Aaron";
    NSDictionary *data = @{@"B": @[p1, p2], @"A": @[p3]};
    [vc updateTableData:data];

    MAVEABPerson *received1 = [vc tableView:vc.tableView personForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    MAVEABPerson *received2 = [vc tableView:vc.tableView personForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    MAVEABPerson *received3 = [vc tableView:vc.tableView personForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    XCTAssertEqualObjects(received1, p1);
    XCTAssertEqualObjects(received2, p2);
    XCTAssertEqualObjects(received3, p3);
}

@end
