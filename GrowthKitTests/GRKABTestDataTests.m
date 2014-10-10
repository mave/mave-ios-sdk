//
//  GRKABTestDataTests.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/26/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AddressBook/AddressBook.h>
#import "GRKABTestDataFactory.h"

@interface GRKABTestDataTests : XCTestCase

@end

@implementation GRKABTestDataTests

- (void)testGenerateABRecordRef {
    ABRecordRef rec = [GRKABTestDataFactory generateABRecordRef];
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(rec, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(rec, kABPersonLastNameProperty);
    XCTAssertNotEqualObjects(firstName, nil);
    XCTAssertNotEqualObjects(lastName, nil);
    if (rec != NULL) CFRelease(rec);
}

- (void)testGenerateABAddressBookRef {
    NSArray *addressBook = [GRKABTestDataFactory generateAddressBookOfSize:3];
    XCTAssertEqual([addressBook count], 3);
    ABRecordRef rec1 = (__bridge ABRecordRef)(addressBook[0]);
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(rec1, kABPersonFirstNameProperty);
    XCTAssertNotEqualObjects(firstName, nil);
    if (rec1 != NULL) CFRelease(rec1);
}

@end
