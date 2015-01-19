//
//  MAVEInviteCopyViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/18/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MaveSDK.h"
#import "MAVEInviteExplanationView.h"

@interface MAVEInviteExplanationViewTests : XCTestCase

@end

@implementation MAVEInviteExplanationViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
    MAVEInviteExplanationView *copyView = [[MAVEInviteExplanationView alloc] init];
    XCTAssertNotNil(copyView);
    XCTAssertNotNil(copyView.messageCopy);
    XCTAssertEqualObjects(copyView.backgroundColor, displayOptions.inviteExplanationCellBackgroundColor);
    XCTAssertEqualObjects(copyView.messageCopy.text, displayOptions.inviteExplanationCopy);
    XCTAssertEqualObjects(copyView.messageCopy.font, displayOptions.inviteExplanationFont);
    XCTAssertEqualObjects(copyView.messageCopy.textColor, displayOptions.inviteExplanationTextColor);
    XCTAssertEqual(copyView.messageCopy.textAlignment, NSTextAlignmentCenter);
    XCTAssertEqual(copyView.messageCopy.lineBreakMode, NSLineBreakByWordWrapping);
    XCTAssertEqual([copyView.subviews count], 1);
}

- (void)testLayoutComputeHeight {
    // Set some default values
    [MaveSDK sharedInstance].displayOptions.inviteExplanationCopy =
        @"Get $20 for each friend you invite, this is some longer text blah";
    [MaveSDK sharedInstance].displayOptions.inviteExplanationFont =
        [UIFont systemFontOfSize:14];
    CGFloat viewWidth = 200;
    // Expected taken by running once with our default values, now we're subtracting the search bar heigh
    CGFloat expectedViewHeight = 90.5;
    MAVEInviteExplanationView *copyView = [[MAVEInviteExplanationView alloc] init];
    CGSize labelSize = [copyView messageCopyLabelSizeWithWidth:viewWidth];

    XCTAssertEqualWithAccuracy(labelSize.width, viewWidth - 2*20, 1);
    XCTAssertEqualWithAccuracy(labelSize.height, expectedViewHeight - 2*20, 1);

    // the invite explanation view itself is smaller b/c of content inset for mave search bar height
    XCTAssertEqualWithAccuracy([copyView computeHeightWithWidth:viewWidth],
                               expectedViewHeight - MAVESearchBarHeight, 1);
}

@end
