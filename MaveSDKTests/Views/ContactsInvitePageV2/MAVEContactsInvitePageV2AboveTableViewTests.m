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

    MAVEContactsInvitePageV2AboveTableView *view = [[MAVEContactsInvitePageV2AboveTableView alloc] init];

    XCTAssertEqualObjects(view.messageLabel.font, opts.messageFieldLabelFont);
    XCTAssertEqualObjects(view.messageLabel.textColor, opts.messageFieldLabelTextColor);
    XCTAssertEqualObjects(view.editButton.titleLabel.textColor, opts.messageFieldLabelTextColor);
    XCTAssertEqualObjects(view.messageTextView.text, [MaveSDK sharedInstance].defaultSMSMessageText);
    XCTAssertEqualObjects(view.messageTextView.font, opts.messageFieldFont);
    XCTAssertEqualObjects(view.messageTextView.textColor, opts.messageFieldTextColor);
    XCTAssertEqualObjects(view.backgroundColor, opts.messageFieldBackgroundColor);
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
