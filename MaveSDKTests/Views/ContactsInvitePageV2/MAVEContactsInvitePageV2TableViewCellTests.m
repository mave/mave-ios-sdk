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
#import "MAVEContactsInvitePageV2TableViewCell2.h"

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

- (void)testAwakeFromNib {
    MAVEContactsInvitePageV2TableViewCell2 *cell = [[MAVEContactsInvitePageV2TableViewCell2 alloc] init];
    id cellMock = OCMPartialMock(cell);
    OCMExpect([cellMock doInitialSetup]);

    [cell awakeFromNib];

    OCMVerifyAll(cellMock);
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
