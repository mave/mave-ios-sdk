//
//  MAVEDisplayOptionsTests.m
//  MaveSDK
//
//  Created by dannycosson on 10/20/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEDisplayOptions.h"
#import "MAVEDisplayOptionsFactory.h"

@interface MAVEDisplayOptionsTests : XCTestCase

@end

@implementation MAVEDisplayOptionsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultOptions {
    MAVEDisplayOptions *opts = [[MAVEDisplayOptions alloc] initWithDefaults];

    UIFont *defaultFont = [UIFont systemFontOfSize:16];
    UIFont *sendButtonFont = [UIFont systemFontOfSize:18];
    UIFont *smallerFont = [UIFont systemFontOfSize:14];
    UIFont *smallerBoldFont = [UIFont boldSystemFontOfSize:14];
    UIFont *smallererFont = [UIFont systemFontOfSize:12];
    UIFont *smallestFont = [UIFont systemFontOfSize:10];
    UIColor *white = [[UIColor alloc] initWithWhite:1.0 alpha:1];
    UIColor *almostBlack = [[UIColor alloc] initWithWhite:0.15 alpha:1.0];
    UIColor *mediumGrey = [[UIColor alloc] initWithWhite:0.65 alpha:1.0];
    UIColor *lightGrey = [[UIColor alloc] initWithWhite:0.70 alpha:1.0];
    UIColor *extraLightGrey = [[UIColor alloc] initWithWhite:0.95 alpha:1.0];
    UIColor *blueTint = [[UIColor alloc] initWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];

    // Header options
    XCTAssertEqual(opts.statusBarStyle, UIStatusBarStyleDefault);
    XCTAssertEqualObjects(opts.navigationBarTitleCopy, @"Invite Friends");
    XCTAssertEqualObjects(opts.navigationBarTitleFont, defaultFont);
    XCTAssertEqualObjects(opts.navigationBarTitleTextColor, almostBlack);
    XCTAssertEqualObjects(opts.navigationBarBackgroundColor, white);
    XCTAssertEqualObjects(opts.navigationBarCancelButton.title, @"Cancel");

    // Above table content - invite page v1 specific
    // Explanation of how the referral program works section (invite page v1)
    XCTAssertEqualObjects(opts.inviteExplanationCopy, nil);
    XCTAssertEqualObjects(opts.inviteExplanationFont, smallerFont);
    XCTAssertEqualObjects(opts.inviteExplanationTextColor, almostBlack);
    XCTAssertEqualObjects(opts.inviteExplanationCellBackgroundColor, extraLightGrey);

    XCTAssertEqualObjects(opts.inviteExplanationShareButtonsColor, mediumGrey);
    XCTAssertEqualObjects(opts.inviteExplanationShareButtonsFont, smallestFont);
    XCTAssertEqualObjects(opts.inviteExplanationShareButtonsBackgroundColor, extraLightGrey);

    // Above table content - invite page v2 specific
    XCTAssertEqualObjects(opts.topViewMessageLabelFont, smallerFont);
    XCTAssertEqualObjects(opts.topViewMessageLabelTextColor, mediumGrey);
    XCTAssertEqualObjects(opts.topViewMessageFont, smallerFont);
    XCTAssertEqualObjects(opts.topViewMessageTextColor, almostBlack);
    XCTAssertEqualObjects(opts.topViewBackgroundColor, extraLightGrey);

    // Search Bar
    XCTAssertEqualObjects(opts.searchBarFont, defaultFont);
    XCTAssertEqualObjects(opts.searchBarPlaceholderTextColor, mediumGrey);
    XCTAssertEqualObjects(opts.searchBarSearchTextColor, almostBlack);
    XCTAssertEqualObjects(opts.searchBarBackgroundColor, white);
    XCTAssertEqualObjects(opts.searchBarTopBorderColor, extraLightGrey);

    // "Friends to invite" table options
    XCTAssertEqualObjects(opts.contactNameFont, defaultFont);
    XCTAssertEqualObjects(opts.contactNameTextColor, almostBlack);
    XCTAssertEqualObjects(opts.contactDetailsFont, smallerFont);
    XCTAssertEqualObjects(opts.contactDetailsTextColor, mediumGrey);
    XCTAssertEqualObjects(opts.contactSeparatorColor, extraLightGrey);
    XCTAssertEqualObjects(opts.contactCellBackgroundColor, white);
    XCTAssertEqualObjects(opts.contactCheckmarkColor, blueTint);
    XCTAssertEqualObjects(opts.contactInlineSendButtonFont, defaultFont);
    XCTAssertEqualObjects(opts.contactInlineSendButtonTextColor, blueTint);
    XCTAssertEqualObjects(opts.contactInlineSendButtonDisabledTextColor, mediumGrey);

    XCTAssertEqualObjects(opts.contactSectionHeaderFont, smallerBoldFont);
    XCTAssertEqualObjects(opts.contactSectionHeaderTextColor, almostBlack);
    XCTAssertEqualObjects(opts.contactSectionHeaderBackgroundColor, extraLightGrey);
    XCTAssertEqualObjects(opts.contactSectionIndexColor, lightGrey);
    XCTAssertEqualObjects(opts.contactSectionIndexBackgroundColor, [UIColor clearColor]);
    
    // Message and Send section options
    XCTAssertEqualObjects(opts.messageFieldFont, defaultFont);
    XCTAssertEqualObjects(opts.messageFieldTextColor, almostBlack);
    XCTAssertEqualObjects(opts.messageFieldBackgroundColor, white);
    XCTAssertEqualObjects(opts.sendButtonCopy, @"Send");
    XCTAssertEqualObjects(opts.sendButtonFont, sendButtonFont);
    XCTAssertEqualObjects(opts.sendButtonTextColor, blueTint);
    XCTAssertEqualObjects(opts.bottomViewBackgroundColor, white);
    XCTAssertEqualObjects(opts.bottomViewBorderColor, mediumGrey);

    // SharePage options
    XCTAssertEqualObjects(opts.sharePageBackgroundColor, extraLightGrey);

    XCTAssertEqualObjects(opts.sharePageIconColor, blueTint);
    XCTAssertEqualObjects(opts.sharePageIconFont, smallererFont);
    XCTAssertEqualObjects(opts.sharePageIconTextColor, mediumGrey);

    XCTAssertEqualObjects(opts.sharePageExplanationFont, defaultFont);
    XCTAssertEqualObjects(opts.sharePageExplanationTextColor, almostBlack);
}

- (void)testFactoryFillsOptions {
    MAVEDisplayOptions *opts = [MAVEDisplayOptionsFactory generateDisplayOptions];

    // Header options
    XCTAssertTrue([opts.navigationBarBackgroundColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.navigationBarTitleTextColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.navigationBarTitleFont isKindOfClass:[UIFont class]]);
    XCTAssertEqualObjects(opts.navigationBarCancelButton.title, @"Cancel");

    // Invite explanation section (invite page v1 only)
    XCTAssertGreaterThan([opts.inviteExplanationCopy length], 0);
    XCTAssertTrue([opts.inviteExplanationFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.inviteExplanationTextColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.inviteExplanationCellBackgroundColor isKindOfClass:[UIColor class]]);

    XCTAssertTrue([opts.inviteExplanationShareButtonsColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.inviteExplanationShareButtonsFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.inviteExplanationShareButtonsBackgroundColor isKindOfClass:[UIColor class]]);

    // Above table message section (invite page v2 only)
    XCTAssertTrue([opts.topViewMessageLabelFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.topViewMessageLabelTextColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.topViewMessageFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.topViewMessageTextColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.topViewBackgroundColor isKindOfClass:[UIColor class]]);

    // Search Bar
    XCTAssertTrue([opts.searchBarFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.searchBarPlaceholderTextColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.searchBarSearchTextColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.searchBarBackgroundColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.searchBarTopBorderColor isKindOfClass:[UIColor class]]);

    // "Friends to invite" table options
    XCTAssertTrue([opts.contactNameFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.contactDetailsFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.contactSectionHeaderFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.contactSectionIndexColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.contactCheckmarkColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.contactInlineSendButtonFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.contactInlineSendButtonTextColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.contactInlineSendButtonDisabledTextColor isKindOfClass:[UIColor class]]);
    
    // Message and Send section options
    XCTAssertTrue([opts.messageFieldFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.messageFieldTextColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.bottomViewBackgroundColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.bottomViewBorderColor isKindOfClass:[UIColor class]]);
    XCTAssertNotNil(opts.sendButtonCopy);
    XCTAssertNotEqualObjects(opts.sendButtonCopy, @"Send");
    XCTAssertTrue([opts.sendButtonFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.sendButtonTextColor isKindOfClass:[UIColor class]]);

    // Share page options
    // background
    XCTAssertTrue([opts.sharePageBackgroundColor isKindOfClass:[UIColor class]]);
    // Explanation text
    XCTAssertTrue([opts.sharePageExplanationFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.sharePageExplanationTextColor isKindOfClass:[UIColor class]]);
    // Icons
    XCTAssertTrue([opts.sharePageIconColor isKindOfClass:[UIColor class]]);
    XCTAssertTrue([opts.sharePageIconFont isKindOfClass:[UIFont class]]);
    XCTAssertTrue([opts.sharePageIconTextColor isKindOfClass:[UIColor class]]);
}

@end
