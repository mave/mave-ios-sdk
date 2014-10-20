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
#import "GRKABTableViewController.h"
#import "GRKABPersonCell.h"

@interface GRKABPersonCellTests : XCTestCase

@end

@implementation GRKABPersonCellTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [GrowthKit setupSharedInstanceWithApplicationID:@"foo123"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCellStyleOnInit {
    // This is the init method called by the table view's dequeue method
    GRKABPersonCell *cell = [[GRKABPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Foo"];
    XCTAssertNotNil(cell);

    GRKDisplayOptions *displayOpts = [GrowthKit sharedInstance].displayOptions;

    XCTAssertEqual(cell.selectionStyle, UITableViewCellSelectionStyleNone);
    XCTAssertEqualObjects(cell.textLabel.font, [UIFont systemFontOfSize:16]);
    XCTAssertEqualObjects(cell.textLabel.textColor, displayOpts.primaryTextColor);
    XCTAssertEqualObjects(cell.detailTextLabel.textColor, displayOpts.secondaryTextColor);
    XCTAssertEqualObjects(cell.tintColor, displayOpts.secondaryTextColor);
}

@end