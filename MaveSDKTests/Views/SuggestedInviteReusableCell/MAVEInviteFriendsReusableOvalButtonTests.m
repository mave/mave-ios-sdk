//
//  MAVEInviteFriendsReusableOvalButtonTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEInviteFriendsReusableOvalButton.h"

@interface MAVEInviteFriendsReusableOvalButtonTests : XCTestCase

@end

@implementation MAVEInviteFriendsReusableOvalButtonTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitializeButton {
    MAVEInviteFriendsReusableOvalButton *button = [[MAVEInviteFriendsReusableOvalButton alloc] init];
    [button setHeight:47.5];
    button.textAndIconColor = [UIColor greenColor];
    [button updateConstraints];

    // add to a container to check that height is laid out as expected
    UIView *testingContainer = [[UIView alloc] init];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [testingContainer addSubview:button];
    [testingContainer layoutIfNeeded];

    XCTAssertNotNil(button.customLabel);
    XCTAssertNotNil(button.customImageView.image);
    XCTAssertEqualObjects(button.customLabel.text, @"Invite friends");
    CGSize size = button.frame.size;
    XCTAssertEqual(size.height, 47.5);
    XCTAssertEqual(size.width, 203);  // set to current width, to make sure it doesn't change

    XCTAssertEqualObjects(button.customLabel.textColor, [UIColor greenColor]);
}

@end
