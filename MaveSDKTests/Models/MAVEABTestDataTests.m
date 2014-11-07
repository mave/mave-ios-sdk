//
//  MAVEABTestDataTests.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/26/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AddressBook/AddressBook.h>
#import "MAVEABTestDataFactory.h"

@interface MAVEABTestDataTests : XCTestCase

@end

@implementation MAVEABTestDataTests

- (void)testGenerateABRecordRef {
    ABRecordRef rec = [MAVEABTestDataFactory generateABRecordRef];
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(rec, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(rec, kABPersonLastNameProperty);
    XCTAssertNotEqualObjects(firstName, nil);
    XCTAssertNotEqualObjects(lastName, nil);
    if (rec != NULL) CFRelease(rec);
}

- (void)testGenerateABAddressBookRef {
    NSArray *addressBook = [MAVEABTestDataFactory generateAddressBookOfSize:3];
    XCTAssertEqual([addressBook count], 3);
    ABRecordRef rec1 = (__bridge ABRecordRef)(addressBook[0]);
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(rec1, kABPersonFirstNameProperty);
    XCTAssertNotEqualObjects(firstName, nil);
    if (rec1 != NULL) CFRelease(rec1);
}

@end
