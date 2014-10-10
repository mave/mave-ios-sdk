//
//  GRKABPersonTests.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AddressBook/AddressBook.h>
#import "GRKABPerson.h"
#import "GRKABTestDataFactory.h"

@interface GRKABPersonTests : XCTestCase {
    ABRecordRef exampleRecordRef;
}

@end

@implementation GRKABPersonTests

- (void)setUp {
    [super setUp];
    ABRecordRef p = ABPersonCreate();
    ABRecordSetValue(p, kABPersonFirstNameProperty, @"John" , nil);
    ABRecordSetValue(p, kABPersonLastNameProperty, @"Smith" , nil);
    
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"808.555.1234", kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(p, kABPersonPhoneProperty, pnmv, nil);
    
    ABMutableMultiValueRef emv = ABMultiValueCreateMutable(kABPersonEmailProperty);
    ABMultiValueAddValueAndLabel(emv, @"jsmith@example.com", kABOtherLabel, NULL);
    ABRecordSetValue(p, kABPersonEmailProperty, emv, nil);
    exampleRecordRef = p;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//
// Initializing the GRKABPerson object
//
- (void)testInitPersonFromABRecordRef {
    GRKABPerson *p = [[GRKABPerson alloc] initFromABRecordRef:exampleRecordRef];
    XCTAssertEqualObjects(p.firstName, @"John");
    XCTAssertEqualObjects(p.lastName, @"Smith");
    XCTAssertEqual([p.phoneNumbers count], 1);
    // Should have converted number to default format
    XCTAssertEqualObjects(p.phoneNumbers[0], @"18085551234");
    XCTAssertEqual([p.phoneNumberLabels count], 1);
    XCTAssertEqualObjects(p.phoneNumberLabels[0], @"_$!<Mobile>!$_");
    
    XCTAssertEqual([p.emailAddresses count], 1);
    XCTAssertEqualObjects(p.emailAddresses[0], @"jsmith@example.com");
    XCTAssertEqual(p.selected, NO);
}

- (void)testPhoneNumbersFromABRecordRef {
    ABRecordRef rec = ABPersonCreate();
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"808.555.1234", kABPersonPhoneMobileLabel, NULL);
    ABMultiValueAddValueAndLabel(pnmv, @"(808) 555- 5678", kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    
    GRKABPerson *p = [[GRKABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqual([p.phoneNumbers count], 2);
    XCTAssertEqual([p.phoneNumberLabels count], 2);
    XCTAssertEqualObjects(p.phoneNumbers[0], @"18085551234");
    XCTAssertEqualObjects(p.phoneNumberLabels[0], @"_$!<Mobile>!$_");
    XCTAssertEqualObjects(p.phoneNumbers[1], @"18085555678");
    XCTAssertEqualObjects(p.phoneNumberLabels[1], @"_$!<Main>!$_");
}

- (void)testPhoneNumbersFromABRecordRefWhenNone {
    ABRecordRef rec = ABPersonCreate();
    GRKABPerson *p = [[GRKABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqual([p.phoneNumbers count], 0);
}

- (void)testEmailAddressesFromABRecordRef {
    ABRecordRef p = ABPersonCreate();
    ABMutableMultiValueRef emv = ABMultiValueCreateMutable(kABPersonEmailProperty);
    ABMultiValueAddValueAndLabel(emv, @"jsmith@example.com", kABOtherLabel, NULL);
    ABMultiValueAddValueAndLabel(emv, @"john.smith@example.com", kABOtherLabel, NULL);
    ABRecordSetValue(p, kABPersonEmailProperty, emv, nil);
    
    NSArray *emails = [GRKABPerson emailAddressesFromABRecordRef:p];
    XCTAssertEqual([emails count], 2);
    XCTAssertEqualObjects(emails[0], @"jsmith@example.com");
    XCTAssertEqualObjects(emails[1], @"john.smith@example.com");
}

- (void)testEmailAddressesFromABRecordRefWhenNone {
    ABRecordRef p = ABPersonCreate();
    NSArray *emails = [GRKABPerson emailAddressesFromABRecordRef:p];
    XCTAssertEqual([emails count], 0);
}

- (void)testInitFailsWhenBothNamesMissing {
    GRKABPerson *p1 = [[GRKABPerson alloc] initFromABRecordRef:ABPersonCreate()];
    XCTAssertEqualObjects(p1, nil);
}

- (void)testInitFailsWhenNoPhones {
    ABRecordRef rec = ABPersonCreate();
    ABRecordSetValue(rec, kABPersonFirstNameProperty, @"John" , nil);
    GRKABPerson *p1 = [[GRKABPerson alloc] initFromABRecordRef:rec];
    XCTAssertEqualObjects(p1, nil);
}
- (void)testInitFailsWhenNoValidPhones {
    ABRecordRef rec = ABPersonCreate();
    ABRecordSetValue(rec, kABPersonFirstNameProperty, @"John" , nil);
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    // phone number is invalid b/c not 10 digits
    ABMultiValueAddValueAndLabel(pnmv, @"555.1234", kABPersonPhoneMobileLabel, NULL);
    GRKABPerson *p1 = [[GRKABPerson alloc] initFromABRecordRef:rec];
    XCTAssertEqualObjects(p1, nil);
}


//
// Methods on the GRKABPerson Object
//
- (void)testFirstLetter {
    GRKABPerson *p1 = [GRKABTestDataFactory personWithFirstName:@"Dan" lastName:@"Foo"];
    GRKABPerson *p2 = [GRKABTestDataFactory personWithFirstName:@"Dan" lastName:@"foo"];
    GRKABPerson *p3 = [GRKABTestDataFactory personWithFirstName:@"dan" lastName:nil];
    XCTAssertEqualObjects([p1 firstLetter], @"F");
    XCTAssertEqualObjects([p2 firstLetter], @"F");
    XCTAssertEqualObjects([p3 firstLetter], @"D");    
}

- (void)testFullNameBoth {
    GRKABPerson *p1 = [GRKABTestDataFactory personWithFirstName:@"Dan" lastName:@"Foo"];
    GRKABPerson *p2 = [GRKABTestDataFactory personWithFirstName:@"Dan" lastName:nil];
    GRKABPerson *p3 = [GRKABTestDataFactory personWithFirstName:nil lastName:@"Foo"];
    GRKABPerson *p4 = [[GRKABPerson alloc] init];
    XCTAssertEqualObjects(p1.fullName, @"Dan Foo");
    XCTAssertEqualObjects(p2.fullName, @"Dan");
    XCTAssertEqualObjects(p3.fullName, @"Foo");
    XCTAssertEqualObjects(p4.fullName, nil);
}

- (void)testBestPhoneSingleNumber {
    NSString *bestPhone = @"18085551234";
    GRKABPerson *p = [[GRKABPerson alloc] init];
    p.phoneNumbers = [[NSArray alloc] initWithObjects:bestPhone, nil];
    XCTAssertEqualObjects([p bestPhone], bestPhone);
}

- (void)testBestPhoneNilIfNoPhones {
    GRKABPerson *p = [[GRKABPerson alloc] init];
    XCTAssertEqualObjects([p bestPhone], nil);
}

// If multiple phone records exist, it should choose the first one listed as Mobile
- (void)testBestPhonePrefersMobile {
    ABRecordRef rec = ABPersonCreate();
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"(808) 555- 5678", kABPersonPhoneMainLabel, NULL);
    ABMultiValueAddValueAndLabel(pnmv, @"808.555.1234", kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    
    GRKABPerson *p = [[GRKABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqualObjects([p bestPhone], @"18085551234");
}

- (void)testBestPhonePreferMainIfNoMobile {
    ABRecordRef rec = ABPersonCreate();
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"(808) 555- 5678", kABPersonPhoneHomeFAXLabel, NULL);
    ABMultiValueAddValueAndLabel(pnmv, @"808.555.1234", kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    
    GRKABPerson *p = [[GRKABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqualObjects([p bestPhone], @"18085551234");
}

- (void)testNormalizePhoneBasicFormats {
    NSString *p1 = @"(808) 555-1234";
    NSString *p2 = @"808.555.1234";
    XCTAssertEqualObjects([GRKABPerson normalizePhoneNumber:p1], @"18085551234");
    XCTAssertEqualObjects([GRKABPerson normalizePhoneNumber:p2], @"18085551234");
}

- (void) testNormalizePhoneIfAlreadyContains1 {
    NSString *p1 = @"+1 (808) 555-1234";
    NSString *p2 = @"+1.808.555.1234";
    NSString *p3 = @"1.808.555.1234";
    XCTAssertEqualObjects([GRKABPerson normalizePhoneNumber:p1], @"18085551234");
    XCTAssertEqualObjects([GRKABPerson normalizePhoneNumber:p2], @"18085551234");
    XCTAssertEqualObjects([GRKABPerson normalizePhoneNumber:p3], @"18085551234");
}

- (void)testNormalizeInvalidPhonesReturnNil {
    // Only US phone numbers (10 digit, optionally starting with 1) are valid currently
    NSString *p1 = @"2.808.555.1234";
    NSString *p2 = @"08.555.1234";
    NSString *p3 = @"notanumber";
    XCTAssertEqualObjects([GRKABPerson normalizePhoneNumber:p1], nil);
    XCTAssertEqualObjects([GRKABPerson normalizePhoneNumber:p2], nil);
    XCTAssertEqualObjects([GRKABPerson normalizePhoneNumber:p3], nil);
}

- (void)testDisplayPhonesWorks {
    NSString *p1 = @"18085551234";
    XCTAssertEqualObjects([GRKABPerson displayPhoneNumber:p1],
                          @"(808)\u00a0555-1234");
}


//
//Comparison methods
//
- (void)testComparePersonsLastNamesSame {
    GRKABPerson *p1 = [GRKABTestDataFactory personWithFirstName:@"D" lastName:@"F"];
    GRKABPerson *p2 = [GRKABTestDataFactory personWithFirstName:@"C" lastName:@"F"];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedDescending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedAscending);
}

- (void)testComparePersonsLastNamesDiffer {
    GRKABPerson *p1 = [GRKABTestDataFactory personWithFirstName:@"D" lastName:@"F"];
    GRKABPerson *p2 = [GRKABTestDataFactory personWithFirstName:@"C" lastName:@"E"];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedDescending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedAscending);
}

- (void)testCompareWhenLastNamesMightBeMissing {
    GRKABPerson *p1 = [GRKABTestDataFactory personWithFirstName:@"D" lastName:@"F"];
    GRKABPerson *p2 = [GRKABTestDataFactory personWithFirstName:@"E" lastName:nil];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedDescending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedAscending);
    
    GRKABPerson *p1_2 = [GRKABTestDataFactory personWithFirstName:@"D" lastName:nil];
    XCTAssertEqual([p1_2 compareNames:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareNames:p1_2], NSOrderedDescending);
}

- (void)testCompareWhenFirstNamesMightBeMissing {
    GRKABPerson *p1 = [GRKABTestDataFactory personWithFirstName:@"D" lastName:@"F"];
    GRKABPerson *p2 = [GRKABTestDataFactory personWithFirstName:nil lastName:@"E"];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedDescending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedAscending);
    
    GRKABPerson *p1_2 = [GRKABTestDataFactory personWithFirstName:nil lastName:@"D"];
    XCTAssertEqual([p1_2 compareNames:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareNames:p1_2], NSOrderedDescending);
}

- (void)testCompareWhenFirstAndLastNamesMightBeMissing {
    GRKABPerson *p1 = [GRKABTestDataFactory personWithFirstName:@"D" lastName:nil];
    GRKABPerson *p2 = [GRKABTestDataFactory personWithFirstName:nil lastName:@"E"];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedDescending);
}

@end