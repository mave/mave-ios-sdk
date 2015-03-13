//
//  MAVEABTestDataTests.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/26/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AddressBook/AddressBook.h>
#import "MAVEABTestDataFactory.h"

@interface MAVEABTestDataTests : XCTestCase

@end

@implementation MAVEABTestDataTests

- (void)testGenerateABRecordRef {
    ABRecordRef rec = MAVECreateABRecordRef();
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(rec, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(rec, kABPersonLastNameProperty);
    XCTAssertNotEqualObjects(firstName, nil);
    XCTAssertNotEqualObjects(lastName, nil);
    if (rec != NULL) CFRelease(rec);
}

- (void)testGenerateABAddressBookRef {
    ABRecordRef rec0 = MAVECreateABRecordRef();
    ABRecordRef rec1 = MAVECreateABRecordRef();
    ABRecordRef rec2 = MAVECreateABRecordRef();
    NSArray *addressBook = @[(__bridge id)rec0, (__bridge id)rec1, (__bridge id)rec2];

    XCTAssertEqual([addressBook count], 3);
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(rec0, kABPersonFirstNameProperty);
    XCTAssertNotEqualObjects(firstName, nil);
}

@end
