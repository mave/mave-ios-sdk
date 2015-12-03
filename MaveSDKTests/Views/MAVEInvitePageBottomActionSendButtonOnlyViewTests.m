//
//  MAVEInvitePageBottomActionSendButtonOnlyViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/5/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MaveSDK.h"
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEInvitePageBottomActionSendButtonOnlyView.h"

@interface MAVEInvitePageBottomActionSendButtonOnlyViewTests : XCTestCase

@end

@implementation MAVEInvitePageBottomActionSendButtonOnlyViewTests

- (void)setUp {
    [super setUp];
    [MaveSDK setupSharedInstance];
    [MaveSDK sharedInstance].displayOptions = [MAVEDisplayOptionsFactory generateDisplayOptions];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    MAVEInvitePageBottomActionSendButtonOnlyView *view = [[MAVEInvitePageBottomActionSendButtonOnlyView alloc] init];
    [view layoutSubviews];

    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;
    XCTAssertEqualObjects(view.backgroundColor, opts.bottomViewBackgroundColor);

    XCTAssertEqualObjects(view.sendButton.titleLabel.text, @"INVITE");
    // This doesn't use the usual send button copy, but does use the usual send button font & color
    XCTAssertNotEqualObjects(view.sendButton.titleLabel.text, opts.sendButtonCopy);
    XCTAssertEqualObjects(view.sendButton.titleLabel.font, opts.sendButtonFont);
    XCTAssertEqualObjects(view.sendButton.titleLabel.textColor, opts.sendButtonTextColor);

    XCTAssertEqualObjects(view.numberSelectedIndicator.text, @"Compose SMS to 0 people");
    XCTAssertEqualObjects(view.numberSelectedIndicator.font, [UIFont systemFontOfSize:10]);
    XCTAssertEqualObjects(view.numberSelectedIndicator.textColor, [MAVEDisplayOptions colorMediumGrey]);
}

@end
