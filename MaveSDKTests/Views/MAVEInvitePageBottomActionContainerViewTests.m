//
//  MAVEInvitePageBottomActionContainerViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/19/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MaveSDK.h"
#import "MAVEInviteTableSectionHeaderView.h"
#import "MAVEDisplayOptionsFactory.h"

@interface MAVEInvitePageBottomActionContainerViewTests : XCTestCase

@end

@implementation MAVEInvitePageBottomActionContainerViewTests

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

- (void)testInitAndSetupNotWaiting {
    MAVEInviteTableSectionHeaderView *view = [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:@"footext" sectionIsWaiting:NO];

    MAVEDisplayOptions *displayOpts = [MaveSDK sharedInstance].displayOptions;
    XCTAssertEqualObjects(view.titleLabel.text, @"footext");
    XCTAssertEqualObjects(view.titleLabel.textColor, displayOpts.contactSectionHeaderTextColor);
    XCTAssertEqualObjects(view.titleLabel.font, displayOpts.contactSectionHeaderFont);
    XCTAssertEqualObjects(view.backgroundColor, displayOpts.contactSectionHeaderBackgroundColor);
    XCTAssertNil(view.waitingDotsView);

    // This is just a no-op bc it's not waiting
    [view stopWaiting];
    XCTAssertNil(view.waitingDotsView);
}

- (void)testInitAndSetupWaiting {
    MAVEInviteTableSectionHeaderView *view = [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:@"bartext" sectionIsWaiting:YES];
    
    XCTAssertEqualObjects(view.titleLabel.text, @"bartext");
    XCTAssertNotNil(view.waitingDotsView);
    XCTAssertFalse(view.waitingDotsView.hidden);

    [view stopWaiting];
    XCTAssertTrue(view.waitingDotsView.hidden);
}

@end
