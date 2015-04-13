//
//  MAVEContactsInvitePageInlineSendButtonTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/13/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEContactsInvitePageInlineSendButton.h"

@interface MAVEContactsInvitePageInlineSendButtonTests : XCTestCase

@end

@implementation MAVEContactsInvitePageInlineSendButtonTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    MAVEContactsInvitePageInlineSendButton *button = [[MAVEContactsInvitePageInlineSendButton alloc] init];

    XCTAssertNotNil(button.sendingStatusSpinner);
    XCTAssertEqual(button.sendingStatusSpinner.frame.size.width, 18);
    XCTAssertEqual(button.sendingStatusSpinner.frame.size.height, 18);
    XCTAssertEqualObjects([button titleForState:UIControlStateNormal], @"Send");
    XCTAssertEqualObjects([button titleForState:UIControlStateDisabled], @"Sent");

    XCTAssertTrue(button.enabled);
}

- (void)testSetStatusUnsent {
    MAVEContactsInvitePageInlineSendButton *button = [[MAVEContactsInvitePageInlineSendButton alloc] init];
    [button setStatusSending];
    [button setStatusUnsent];

    XCTAssertTrue(button.enabled);
    XCTAssertEqualObjects([button titleForState:UIControlStateNormal], @"Send");
    XCTAssertFalse([button.sendingStatusSpinner isDescendantOfView:button]);
}

- (void)testSetStatusSending {
    MAVEContactsInvitePageInlineSendButton *button = [[MAVEContactsInvitePageInlineSendButton alloc] init];
    [button setStatusUnsent];
    [button setStatusSending];

    XCTAssertFalse(button.enabled);
    XCTAssertEqualObjects([button titleForState:UIControlStateDisabled], @"    ");
    XCTAssertTrue([button.sendingStatusSpinner isDescendantOfView:button]);
}

- (void)testSetStatusSent {
    MAVEContactsInvitePageInlineSendButton *button = [[MAVEContactsInvitePageInlineSendButton alloc] init];
    [button setStatusSending];
    [button setStatusSent];

    XCTAssertFalse(button.enabled);
    XCTAssertEqualObjects([button titleForState:UIControlStateDisabled], @"Sent");
    XCTAssertFalse([button.sendingStatusSpinner isDescendantOfView:button]);
}

@end
