//
//  MAVEInviteMessageViewTests.m
//  MaveSDK
//
//  Created by dannycosson on 10/19/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVEDisplayOptions.h"
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEInviteMessageView.h"
#import "MAVEInviteSendingProgressView.h"

@interface MAVEInviteMessageViewTests : XCTestCase

@end

@implementation MAVEInviteMessageViewTests

- (void)setUp {
    [super setUp];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    [MaveSDK sharedInstance].displayOptions = [MAVEDisplayOptionsFactory generateDisplayOptions];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMessageViewStyleOnInit {
    // Setup and get opts to compare it to
    [MaveSDK sharedInstance].defaultSMSMessageText = @"tmp message";
    MAVEInviteMessageView *view = [[MAVEInviteMessageView alloc] init];
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;

    // Test view box style
    XCTAssertEqualObjects(view.backgroundColor, opts.bottomViewBackgroundColor);
    XCTAssertEqualObjects(view.fakeTopBorder.backgroundColor, opts.bottomViewBorderColor);
    
    // Test Message field style & content
    UIColor *tfBorderColor = [[UIColor alloc]
                              initWithCGColor:view.textView.layer.borderColor];
    XCTAssertEqualObjects(tfBorderColor, opts.bottomViewBorderColor);
    XCTAssertEqualObjects(view.textView.text, @"tmp message");
    XCTAssertEqualObjects(view.textView.font, opts.messageFieldFont);
    XCTAssertEqualObjects(view.textView.textColor, opts.messageFieldTextColor);
    XCTAssertEqualObjects(view.textView.backgroundColor, opts.messageFieldBackgroundColor);

    // Test Button Style
    XCTAssertFalse(view.sendButton.enabled);
    XCTAssertEqualObjects([view.sendButton titleForState:UIControlStateNormal], @"Send");
    XCTAssertEqualObjects([view.sendButton titleColorForState:UIControlStateNormal], opts.sendButtonTextColor);
    XCTAssertEqualObjects([view.sendButton titleForState:UIControlStateDisabled], @"Send");
    XCTAssertEqualObjects([view.sendButton titleColorForState:UIControlStateDisabled],
                          [MAVEDisplayOptions colorMediumGrey]);
    
    // Send Medium Indicator Style
    XCTAssertEqualObjects(view.sendMediumIndicator.text, @"Individual SMS");
    XCTAssertEqualObjects(view.sendMediumIndicator.textColor, [MAVEDisplayOptions colorMediumGrey]);
    XCTAssertEqualObjects(view.sendMediumIndicator.font, opts.contactDetailsFont);
}

- (void)testSendingProgressViewStyleOnInit {
    MAVEInviteSendingProgressView *view = [[MAVEInviteSendingProgressView alloc] init];
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;

    XCTAssertEqualObjects(view.backgroundColor, opts.bottomViewBackgroundColor);
    XCTAssertEqualObjects(view.progressView.tintColor, opts.sendButtonTextColor);
    XCTAssertEqualObjects(view.mainLabel.textColor, opts.sendButtonTextColor);
}

- (void)testUpdateNumberPeopleSelectedNonZero {
    MAVEInviteMessageView *view = [[MAVEInviteMessageView alloc] init];
    id partialMock = [OCMockObject partialMockForObject:view];
    [[partialMock expect] setNeedsLayout];
    
    [view updateNumberPeopleSelected:3];
    
    XCTAssertEqualObjects(view.sendMediumIndicator.text, @"3 Individual SMS");
    XCTAssertTrue(view.sendButton.enabled);
    [partialMock verify];
}

- (void)testUpdateNumberPeopleSelectedZero {
    MAVEInviteMessageView *view = [[MAVEInviteMessageView alloc] init];

    [view updateNumberPeopleSelected:0];
    XCTAssertEqualObjects(view.sendMediumIndicator.text, @"Individual SMS");
    XCTAssertFalse(view.sendButton.enabled);
}

@end