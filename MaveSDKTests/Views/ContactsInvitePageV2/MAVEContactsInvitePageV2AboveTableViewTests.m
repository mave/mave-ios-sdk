//
//  MAVEContactsInvitePageV2AboveTableViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/10/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEDisplayOptionsFactory.h"
#import "MaveSDK.h"
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
    MAVEDisplayOptions *opts = [MAVEDisplayOptionsFactory generateDisplayOptions];
    [MaveSDK sharedInstance].displayOptions = opts;
    [MaveSDK sharedInstance].defaultSMSMessageText = @"Foobar";

    MAVEContactsInvitePageV2AboveTableView *view = [[MAVEContactsInvitePageV2AboveTableView alloc] init];

    XCTAssertEqualObjects(view.messageLabel.font, opts.topViewMessageLabelFont);
    XCTAssertEqualObjects(view.messageLabel.textColor, opts.topViewMessageLabelTextColor);
    XCTAssertEqualObjects(view.messageTextView.font, opts.topViewMessageFont);
    XCTAssertEqualObjects(view.messageTextView.textColor, opts.topViewMessageTextColor);
    XCTAssertEqualObjects(view.backgroundColor, opts.topViewBackgroundColor);

    XCTAssertEqualObjects(view.editButton.titleLabel.textColor, opts.topViewMessageLabelTextColor);
    XCTAssertEqualObjects(view.messageTextView.text, [MaveSDK sharedInstance].defaultSMSMessageText);
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
