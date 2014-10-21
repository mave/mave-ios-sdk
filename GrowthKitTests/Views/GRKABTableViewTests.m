//
//  GRKABPersonCellTests.m
//  GrowthKit
//
//  Created by dannycosson on 10/20/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "GrowthKit.h"
#import "GRKDisplayOptions.h"
#import "GRKDisplayOptionsFactory.h"
#import "GRKABTableViewController.h"
#import "GRKABPersonCell.h"

@interface GRKABTableViewTests : XCTestCase

@end

@implementation GRKABTableViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
    [GrowthKit sharedInstance].displayOptions = [GRKDisplayOptionsFactory generateDisplayOptions];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPersonCellStyleOnInit {
    // This is the init method called by the table view's dequeue method
    GRKABPersonCell *cell = [[GRKABPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Foo"];
    XCTAssertNotNil(cell);

    GRKDisplayOptions *displayOpts = [GrowthKit sharedInstance].displayOptions;

    XCTAssertEqual(cell.selectionStyle, UITableViewCellSelectionStyleNone);
    XCTAssertEqualObjects(cell.textLabel.font, displayOpts.primaryFont);
    XCTAssertEqualObjects(cell.textLabel.textColor, displayOpts.primaryTextColor);
    XCTAssertEqualObjects(cell.detailTextLabel.textColor, displayOpts.secondaryTextColor);
    XCTAssertEqualObjects(cell.tintColor, displayOpts.secondaryTextColor);
}

- (void)testTableSectionStyle {
    CGRect fakeFrame = CGRectMake(0, 0, 0, 0);
    NSDictionary *data = @{@"D": @[@"Danny"]};
    GRKABTableViewController *vc = [[GRKABTableViewController alloc] initTableViewWithFrame:fakeFrame];
    [vc updateTableData:data];
    GRKDisplayOptions *opts = [GrowthKit sharedInstance].displayOptions;

    UIView *sectionHeaderView = [vc tableView:vc.tableView viewForHeaderInSection:0];
    XCTAssertEqualObjects(sectionHeaderView.backgroundColor, opts.tableSectionHeaderBackgroundColor);
    UILabel *headerLabel = (UILabel *)sectionHeaderView.subviews[0];
    XCTAssertEqualObjects(headerLabel.text, @"D");
    XCTAssertEqualObjects(headerLabel.textColor, opts.primaryTextColor);
    XCTAssertEqualObjects(headerLabel.font, opts.primaryFont);
}

@end