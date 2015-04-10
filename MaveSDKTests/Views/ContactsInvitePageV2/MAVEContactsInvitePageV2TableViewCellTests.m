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
#import "MAVEContactsInvitePageV2TableViewCell2.h"
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEBuiltinUIElementUtils.h"

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

    MAVEContactsInvitePageV2TableViewCell2 *cell = [[MAVEContactsInvitePageV2TableViewCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"foo"];

    XCTAssertEqual(cell.selectionStyle, UITableViewCellSelectionStyleNone);
    XCTAssertEqualObjects(cell.sendButton.titleLabel.font, opts.sendButtonFont);
    XCTAssertEqualObjects([cell.sendButton titleForState:UIControlStateNormal], opts.sendButtonCopy);
    XCTAssertEqualObjects([cell.sendButton titleForState:UIControlStateSelected], @"Sending...");
    XCTAssertEqualObjects([cell.sendButton titleForState:UIControlStateDisabled], @"Sent");
    XCTAssertEqualObjects([cell.sendButton titleColorForState:UIControlStateNormal], opts.sendButtonTextColor);
    XCTAssertEqualObjects([cell.sendButton titleColorForState:UIControlStateSelected], opts.sendButtonDisabledTextColor);
    XCTAssertEqualObjects([cell.sendButton titleColorForState:UIControlStateDisabled], opts.sendButtonDisabledTextColor);
}

- (void)testUpdateWithInfoForPerson {
    MAVEContactsInvitePageV2TableViewCell2 *cell = [[MAVEContactsInvitePageV2TableViewCell2 alloc] init];
    cell.nameLabel = [[UILabel alloc] init];
    cell.contactInfoLabel = [[UILabel alloc] init];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Peter";
    p1.lastName = @"Foo";
    p1.phoneNumbers = @[@"+18085551111"];
    XCTAssertEqualObjects(p1.bestPhone, @"+18085551111");

    [cell updateWithInfoForPerson:p1];
    XCTAssertEqualObjects(cell.nameLabel.text, @"Peter Foo");
    XCTAssertEqualObjects(cell.contactInfoLabel.text, @"(808)\u00a0555-1111");
}

@end
