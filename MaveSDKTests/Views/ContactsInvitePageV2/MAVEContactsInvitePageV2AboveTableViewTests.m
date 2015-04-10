//
//  MAVEContactsInvitePageV2AboveTableViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/10/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEContactsInvitePageV2AboveTableView.h"

@interface MAVEContactsInvitePageV2AboveTableViewTests : XCTestCase

@end

@implementation MAVEContactsInvitePageV2AboveTableViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitialSetup {
    MAVEContactsInvitePageV2AboveTableView *view = [[MAVEContactsInvitePageV2AboveTableView alloc] init];

}

- (void)testToggleMessageTextViewEditable {
    MAVEContactsInvitePageV2AboveTableView *view = [[MAVEContactsInvitePageV2AboveTableView alloc] init];
    XCTAssertFalse(view.messageTextView.editable);
    NSArray *actions = [view.editButton actionsForTarget:view forControlEvent:UIControlEventTouchUpInside];
    XCTAssertEqual([actions count], 1);
    XCTAssertEqualObjects(actions[0], @"toggleMessageTextViewEditable");

    [view toggleMessageTextViewEditable];
    XCTAssertTrue(view.messageTextView.editable);

    [view toggleMessageTextViewEditable];
    XCTAssertFalse(view.messageTextView.editable);
}

@end
