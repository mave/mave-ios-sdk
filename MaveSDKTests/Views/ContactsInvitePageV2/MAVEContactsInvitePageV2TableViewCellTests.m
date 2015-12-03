//
//  MAVEContactsInvitePageV2TableViewCellTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVEContactsInvitePageV2TableViewCell.h"
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEBuiltinUIElementUtils.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEContactsInvitePageV2TableViewCellTests : XCTestCase

@end

@implementation MAVEContactsInvitePageV2TableViewCellTests

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

    MAVEContactsInvitePageV2TableViewCell *cell = [[MAVEContactsInvitePageV2TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"foo"];

    XCTAssertEqual(cell.selectionStyle, UITableViewCellSelectionStyleNone);
    XCTAssertEqualObjects(cell.backgroundColor, opts.contactCellBackgroundColor);
    XCTAssertFalse(cell.isSuggestedInviteCell);

    // Name & detail labels
    XCTAssertEqualObjects(cell.nameLabel.font, opts.contactNameFont);
    XCTAssertEqualObjects(cell.nameLabel.textColor, opts.contactNameTextColor);
    XCTAssertEqualObjects(cell.detailLabel.font, opts.contactDetailsFont);
    XCTAssertEqualObjects(cell.detailLabel.textColor, opts.contactDetailsTextColor);

    // Send Button
    XCTAssertNotNil(cell.sendButton);
    NSArray *buttonActions = [cell.sendButton actionsForTarget:cell forControlEvent:UIControlEventTouchUpInside];
    XCTAssertEqual([buttonActions count], 1);
    XCTAssertEqualObjects([buttonActions objectAtIndex:0], @"sendInviteToCurrentPerson");
}

- (void)testHeightCellWillHave {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstance];

    // hard code the default height
    CGFloat height = [MAVEContactsInvitePageV2TableViewCell heightCellWithHave];
    XCTAssertEqual(round(height), 52.0);
}

- (void)testUpdateWithInfoForPerson {
    MAVEContactsInvitePageV2TableViewCell *cell = [[MAVEContactsInvitePageV2TableViewCell alloc] init];
    [cell doCreateSubviews];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Peter";
    p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"+18085551111"];
    XCTAssertEqualObjects(p1.bestPhone, @"+18085551111");

    [cell updateWithInfoForPerson:p1];
    XCTAssertEqualObjects(cell.nameLabel.text, @"Peter Foo");
    XCTAssertEqualObjects(cell.detailLabel.text, @"(808)\u00a0555-1111");
}

- (void)testUpdateWithInfoForPersonWhenStatusUnsent {
    MAVEContactsInvitePageV2TableViewCell *cell = [[MAVEContactsInvitePageV2TableViewCell alloc] init];
    [cell doCreateSubviews];

    id sendButtonMock = OCMPartialMock(cell.sendButton);
    OCMExpect([sendButtonMock setStatusUnsent]);
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.sendingStatus = MAVEInviteSendingStatusUnsent;

    [cell updateWithInfoForPerson:p1];
    OCMVerifyAll(sendButtonMock);
}

- (void)testUpdateWithInfoForPersonWhenStatusSending {
    MAVEContactsInvitePageV2TableViewCell *cell = [[MAVEContactsInvitePageV2TableViewCell alloc] init];
    [cell doCreateSubviews];

    id sendButtonMock = OCMPartialMock(cell.sendButton);
    OCMExpect([sendButtonMock setStatusSending]);
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.sendingStatus = MAVEInviteSendingStatusSending;

    [cell updateWithInfoForPerson:p1];
    OCMVerifyAll(sendButtonMock);
}

- (void)testUpdateWithInfoForPersonWhenStatusSent {
    MAVEContactsInvitePageV2TableViewCell *cell = [[MAVEContactsInvitePageV2TableViewCell alloc] init];
    [cell doCreateSubviews];

    id sendButtonMock = OCMPartialMock(cell.sendButton);
    OCMExpect([sendButtonMock setStatusSent]);
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.sendingStatus = MAVEInviteSendingStatusSent;

    [cell updateWithInfoForPerson:p1];
    OCMVerifyAll(sendButtonMock);
}


@end
