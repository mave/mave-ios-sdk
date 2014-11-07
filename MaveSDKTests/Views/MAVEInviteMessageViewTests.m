//
//  MAVEInviteMessageViewTests.m
//  Mave
//
//  Created by dannycosson on 10/19/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "Mave.h"
#import "MAVEDisplayOptions.h"
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEInviteMessageView.h"
#import "MAVEInviteSendingProgressView.h"

@interface MAVEInviteMessageViewTests : XCTestCase

@end

@implementation MAVEInviteMessageViewTests

- (void)setUp {
    [super setUp];
    [Mave setupSharedInstanceWithApplicationID:@"foo123"];
    [Mave sharedInstance].displayOptions = [MAVEDisplayOptionsFactory generateDisplayOptions];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMessageViewStyleOnInit {
    // Setup and get opts to compare it to
    CGRect fakeFrame = CGRectMake(0, 0, 0, 0);
    MAVEInviteMessageView *view = [[MAVEInviteMessageView alloc] initWithFrame:fakeFrame];
    MAVEDisplayOptions *opts = [Mave sharedInstance].displayOptions;

    // Test view box style
    XCTAssertEqualObjects(view.backgroundColor, opts.bottomViewBackgroundColor);
    XCTAssertEqualObjects(view.fakeTopBorder.backgroundColor, opts.bottomViewBorderColor);
    XCTAssertEqual(view.fakeTopBorder.frame.size.height, 0.5f);
    XCTAssertEqual(view.fakeTopBorder.frame.origin.x, 0);
    XCTAssertEqual(view.fakeTopBorder.frame.origin.y, 0);
    
    // Test Message field style
    UIColor *tfbgColor = [[UIColor alloc]
                          initWithCGColor:view.textField.layer.backgroundColor];
    XCTAssertEqualObjects(tfbgColor, [MAVEDisplayOptions colorWhite]);
    UIColor *tfBorderColor = [[UIColor alloc]
                              initWithCGColor:view.textField.layer.borderColor];
    XCTAssertEqualObjects(tfBorderColor, opts.bottomViewBorderColor);

    // Test Button Style
    XCTAssertFalse(view.sendButton.enabled);
    XCTAssertEqualObjects([view.sendButton titleForState:UIControlStateNormal], @"Send");
    XCTAssertEqualObjects([view.sendButton titleColorForState:UIControlStateNormal], opts.sendButtonColor);
    XCTAssertEqualObjects([view.sendButton titleForState:UIControlStateDisabled], @"Send");
    XCTAssertEqualObjects([view.sendButton titleColorForState:UIControlStateDisabled],
                          [MAVEDisplayOptions colorMediumGrey]);
    
    // Send Medium Indicator Style
    XCTAssertEqualObjects(view.sendMediumIndicator.text, @"Individual SMS");
    XCTAssertEqualObjects(view.sendMediumIndicator.textColor, [MAVEDisplayOptions colorMediumGrey]);
    XCTAssertEqualObjects(view.sendMediumIndicator.font, opts.personContactInfoFont);
}

- (void)testSendingProgressViewStyleOnInit {
    CGRect fakeFrame = CGRectMake(0, 0, 0, 0);
    MAVEInviteSendingProgressView *view = [[MAVEInviteSendingProgressView alloc] initWithFrame:fakeFrame];
    MAVEDisplayOptions *opts = [Mave sharedInstance].displayOptions;

    XCTAssertEqualObjects(view.backgroundColor, opts.bottomViewBackgroundColor);
    XCTAssertEqualObjects(view.progressView.tintColor, opts.sendButtonColor);
    XCTAssertEqualObjects(view.mainLabel.textColor, opts.sendButtonColor);
}

- (void)testUpdateNumberPeopleSelectedNonZero {
    MAVEInviteMessageView *view = [[MAVEInviteMessageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    id partialMock = [OCMockObject partialMockForObject:view];
    [[partialMock expect] setNeedsLayout];
    
    [view updateNumberPeopleSelected:3];
    
    XCTAssertEqualObjects(view.sendMediumIndicator.text, @"3 Individual SMS");
    XCTAssertTrue(view.sendButton.enabled);
    [partialMock verify];
}

- (void)testUpdateNumberPeopleSelectedZero {
    MAVEInviteMessageView *view = [[MAVEInviteMessageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

    [view updateNumberPeopleSelected:0];
    XCTAssertEqualObjects(view.sendMediumIndicator.text, @"Individual SMS");
    XCTAssertFalse(view.sendButton.enabled);
}

@end