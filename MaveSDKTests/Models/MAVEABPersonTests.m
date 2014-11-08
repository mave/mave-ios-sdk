//
//  MAVEABPersonTests.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AddressBook/AddressBook.h>
#import "MAVEABPerson.h"
#import "MAVEABTestDataFactory.h"

@interface MAVEABPersonTests : XCTestCase {
    ABRecordRef exampleRecordRef;
}

@end

@implementation MAVEABPersonTests

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
// Initializing the MAVEABPerson object
//
- (void)testInitPersonFromABRecordRef {
    MAVEABPerson *p = [[MAVEABPerson alloc] initFromABRecordRef:exampleRecordRef];
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
    
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqual([p.phoneNumbers count], 2);
    XCTAssertEqual([p.phoneNumberLabels count], 2);
    XCTAssertEqualObjects(p.phoneNumbers[0], @"18085551234");
    XCTAssertEqualObjects(p.phoneNumberLabels[0], @"_$!<Mobile>!$_");
    XCTAssertEqualObjects(p.phoneNumbers[1], @"18085555678");
    XCTAssertEqualObjects(p.phoneNumberLabels[1], @"_$!<Main>!$_");
}

- (void)testPhoneNumbersFromABRecordRefNilLabel {
    ABRecordRef rec = ABPersonCreate();
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"808.555.1234", nil, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqual([p.phoneNumbers count], 1);
    XCTAssertEqual([p.phoneNumberLabels count], 1);
    XCTAssertEqualObjects(p.phoneNumbers[0], @"18085551234");
    XCTAssertEqualObjects(p.phoneNumberLabels[0], @"_$!<OtherFAX>!$_");
}

- (void)testPhoneNumbersFromABRecordRefWhenNone {
    ABRecordRef rec = ABPersonCreate();
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqual([p.phoneNumbers count], 0);
}

- (void)testPhoneNumbersFromABRecordRefWhenSomeMalformed {
    ABRecordRef rec = ABPersonCreate();
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"5551234", nil, NULL);
    ABMultiValueAddValueAndLabel(pnmv, @"8085551234", kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);

    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqual([p.phoneNumbers count], 1);
    XCTAssertEqual([p.phoneNumberLabels count], 1);
    XCTAssertEqualObjects(p.phoneNumbers[0], @"18085551234");
    XCTAssertEqualObjects(p.phoneNumberLabels[0], @"_$!<Main>!$_");
}

- (void)testEmailAddressesFromABRecordRef {
    ABRecordRef p = ABPersonCreate();
    ABMutableMultiValueRef emv = ABMultiValueCreateMutable(kABPersonEmailProperty);
    ABMultiValueAddValueAndLabel(emv, @"jsmith@example.com", kABOtherLabel, NULL);
    ABMultiValueAddValueAndLabel(emv, @"john.smith@example.com", kABOtherLabel, NULL);
    ABRecordSetValue(p, kABPersonEmailProperty, emv, nil);
    
    NSArray *emails = [MAVEABPerson emailAddressesFromABRecordRef:p];
    XCTAssertEqual([emails count], 2);
    XCTAssertEqualObjects(emails[0], @"jsmith@example.com");
    XCTAssertEqualObjects(emails[1], @"john.smith@example.com");
}

- (void)testEmailAddressesFromABRecordRefWhenNone {
    ABRecordRef p = ABPersonCreate();
    NSArray *emails = [MAVEABPerson emailAddressesFromABRecordRef:p];
    XCTAssertEqual([emails count], 0);
}

- (void)testInitFailsWhenBothNamesMissing {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] initFromABRecordRef:ABPersonCreate()];
    XCTAssertEqualObjects(p1, nil);
}

- (void)testInitFailsWhenNoPhones {
    ABRecordRef rec = ABPersonCreate();
    ABRecordSetValue(rec, kABPersonFirstNameProperty, @"John" , nil);
    MAVEABPerson *p1 = [[MAVEABPerson alloc] initFromABRecordRef:rec];
    XCTAssertEqualObjects(p1, nil);
}
- (void)testInitFailsWhenNoValidPhones {
    ABRecordRef rec = ABPersonCreate();
    ABRecordSetValue(rec, kABPersonFirstNameProperty, @"John" , nil);
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    // phone number is invalid b/c not 10 digits
    ABMultiValueAddValueAndLabel(pnmv, @"555.1234", kABPersonPhoneMobileLabel, NULL);
    MAVEABPerson *p1 = [[MAVEABPerson alloc] initFromABRecordRef:rec];
    XCTAssertEqualObjects(p1, nil);
}


//
// Methods on the MAVEABPerson Object
//
- (void)testFirstLetter {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"Dan" lastName:@"Foo"];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:@"Dan" lastName:@"foo"];
    MAVEABPerson *p3 = [MAVEABTestDataFactory personWithFirstName:@"dan" lastName:nil];
    MAVEABPerson *p4 = [MAVEABTestDataFactory personWithFirstName:nil lastName:@"Foo"];
    XCTAssertEqualObjects([p1 firstLetter], @"D");
    XCTAssertEqualObjects([p2 firstLetter], @"D");
    XCTAssertEqualObjects([p3 firstLetter], @"D");
    XCTAssertEqualObjects([p4 firstLetter], @"F");
}

- (void)testFullNameBoth {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"Dan" lastName:@"Foo"];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:@"Dan" lastName:nil];
    MAVEABPerson *p3 = [MAVEABTestDataFactory personWithFirstName:nil lastName:@"Foo"];
    MAVEABPerson *p4 = [[MAVEABPerson alloc] init];
    XCTAssertEqualObjects(p1.fullName, @"Dan Foo");
    XCTAssertEqualObjects(p2.fullName, @"Dan");
    XCTAssertEqualObjects(p3.fullName, @"Foo");
    XCTAssertEqualObjects(p4.fullName, nil);
}

- (void)testBestPhoneSingleNumber {
    NSString *bestPhone = @"18085551234";
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    p.phoneNumbers = [[NSArray alloc] initWithObjects:bestPhone, nil];
    XCTAssertEqualObjects([p bestPhone], bestPhone);
}

- (void)testBestPhoneNilIfNoPhones {
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    XCTAssertEqualObjects([p bestPhone], nil);
}

// If multiple phone records exist, it should choose the first one listed as Mobile
- (void)testBestPhonePrefersMobile {
    ABRecordRef rec = ABPersonCreate();
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"(808) 555- 5678", kABPersonPhoneMainLabel, NULL);
    ABMultiValueAddValueAndLabel(pnmv, @"808.555.1234", kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqualObjects([p bestPhone], @"18085551234");
}

- (void)testBestPhonePreferMainIfNoMobile {
    ABRecordRef rec = ABPersonCreate();
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"(808) 555- 5678", kABPersonPhoneHomeFAXLabel, NULL);
    ABMultiValueAddValueAndLabel(pnmv, @"808.555.1234", kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqualObjects([p bestPhone], @"18085551234");
}


- (void)testNormalizePhoneBasicFormats {
    NSString *p1 = @"(808) 555-1234";
    NSString *p2 = @"808.555.1234";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], @"18085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p2], @"18085551234");
}

- (void) testNormalizePhoneIfAlreadyContains1 {
    NSString *p1 = @"+1 (808) 555-1234";
    NSString *p2 = @"+1.808.555.1234";
    NSString *p3 = @"1.808.555.1234";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], @"18085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p2], @"18085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p3], @"18085551234");
}

- (void)testNormalizeInvalidPhonesReturnNil {
    // Only US phone numbers (10 digit, optionally starting with 1) are valid currently
    NSString *p1 = @"2.808.555.1234";
    NSString *p2 = @"08.555.1234";
    NSString *p3 = @"notanumber";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], nil);
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p2], nil);
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p3], nil);
}

- (void)testDisplayPhonesWorks {
    NSString *p1 = @"18085551234";
    XCTAssertEqualObjects([MAVEABPerson displayPhoneNumber:p1],
                          @"(808)\u00a0555-1234");
}


//
//Comparison methods
//
- (void)testComparePersonsLastNamesSame {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"D" lastName:@"F"];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:@"C" lastName:@"F"];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedDescending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedAscending);
}

- (void)testComparePersonsLastNamesDiffer {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"C" lastName:@"F"];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:@"D" lastName:@"E"];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedDescending);
}

- (void)testCompareWhenLastNamesMightBeMissing {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"D" lastName:@"F"];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:@"E" lastName:nil];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedDescending);
    
    MAVEABPerson *p1_2 = [MAVEABTestDataFactory personWithFirstName:@"D" lastName:nil];
    XCTAssertEqual([p1_2 compareNames:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareNames:p1_2], NSOrderedDescending);
}

- (void)testCompareWhenFirstNamesMightBeMissing {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"D" lastName:@"F"];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:nil lastName:@"E"];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedDescending);
    
    MAVEABPerson *p1_2 = [MAVEABTestDataFactory personWithFirstName:nil lastName:@"D"];
    XCTAssertEqual([p1_2 compareNames:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareNames:p1_2], NSOrderedDescending);
}

- (void)testCompareWhenFirstAndLastNamesMightBeMissing {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"D" lastName:nil];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:nil lastName:@"E"];
    XCTAssertEqual([p1 compareNames:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareNames:p1], NSOrderedDescending);
}

@end