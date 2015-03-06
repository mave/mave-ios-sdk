//
//  MAVEInvitePageBottomActionSendButtonOnlyViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/5/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEInvitePageBottomActionSendButtonOnlyView.h"

@interface MAVEInvitePageBottomActionSendButtonOnlyViewTests : XCTestCase

@end

@implementation MAVEInvitePageBottomActionSendButtonOnlyViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    MAVEInvitePageBottomActionSendButtonOnlyView *view = [[MAVEInvitePageBottomActionSendButtonOnlyView alloc] init];
    XCTAssertEqualObjects(view.sendButton.titleLabel.text, @"SEND");
    XCTAssertNotNil(view.numberSelectedIndicator);
}

@end
