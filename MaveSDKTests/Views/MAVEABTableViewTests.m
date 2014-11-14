//
//  MAVEABPersonCellTests.m
//  MaveSDK
//
//  Created by dannycosson on 10/20/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
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
    CGRect fakeFrame = CGRectMake(0, 0, 0, 0);
    NSDictionary *data = @{@"D": @[@"Danny"]};
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] initTableViewWithFrame:fakeFrame parent:nil];
    [vc updateTableData:data];
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
    XCTAssertEqualObjects(vc.tableView.sectionIndexColor, displayOptions.sectionIndexColor);
    XCTAssertEqualObjects(vc.tableView.sectionIndexBackgroundColor, displayOptions.sectionIndexBackgroundColor);
}

- (void)testPersonCellStyleOnInit {
    // This is the init method called by the table view's dequeue method
    MAVEABPersonCell *cell = [[MAVEABPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Foo"];
    XCTAssertNotNil(cell);

    MAVEDisplayOptions *displayOpts = [MaveSDK sharedInstance].displayOptions;

    XCTAssertEqual(cell.selectionStyle, UITableViewCellSelectionStyleNone);
    XCTAssertEqualObjects(cell.textLabel.font, displayOpts.personNameFont);
    XCTAssertEqualObjects(cell.textLabel.textColor, displayOpts.personNameColor);
    XCTAssertEqualObjects(cell.detailTextLabel.font, displayOpts.personContactInfoFont);
    XCTAssertEqualObjects(cell.detailTextLabel.textColor, displayOpts.personContactInfoColor);
    XCTAssertEqualObjects(cell.backgroundColor, displayOpts.personCellBackgroundColor);
    XCTAssertEqualObjects(cell.tintColor, displayOpts.checkmarkColor);
}

- (void)testTableSectionStyle {
    CGRect fakeFrame = CGRectMake(0, 0, 0, 0);
    NSDictionary *data = @{@"D": @[@"Danny"]};
    MAVEABTableViewController *vc = [[MAVEABTableViewController alloc] initTableViewWithFrame:fakeFrame parent:nil];
    [vc updateTableData:data];
    MAVEDisplayOptions *displayOpts = [MaveSDK sharedInstance].displayOptions;

    UIView *sectionHeaderView = [vc tableView:vc.tableView viewForHeaderInSection:0];
    XCTAssertEqualObjects(sectionHeaderView.backgroundColor, displayOpts.sectionHeaderBackgroundColor);
    UILabel *headerLabel = (UILabel *)sectionHeaderView.subviews[0];
    XCTAssertEqualObjects(headerLabel.text, @"D");
    XCTAssertEqualObjects(headerLabel.textColor, displayOpts.sectionHeaderColor);
    XCTAssertEqualObjects(headerLabel.font, displayOpts.sectionHeaderFont);
}

@end