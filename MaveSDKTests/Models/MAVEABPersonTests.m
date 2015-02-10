//
//  MAVEABPersonTests.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <OCMock/OCMock.h>
#import <AddressBook/AddressBook.h>
#import "MAVEABPerson.h"
#import "MAVEABTestDataFactory.h"
#import "MAVEMerkleTreeHashUtils.h"

@interface MAVEABPersonTests : XCTestCase

@end

@implementation MAVEABPersonTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//
// Initializing the MAVEABPerson object
//
- (void)testInitPersonFromABRecordRef {
    // Set up ABRecordRefManually
    ABRecordRef pref = ABPersonCreate();
    ABRecordSetValue(pref, kABPersonFirstNameProperty, @"John" , nil);
    ABRecordSetValue(pref, kABPersonLastNameProperty, @"Smith" , nil);

    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"808.555.1234", kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(pref, kABPersonPhoneProperty, pnmv, nil);

    ABMutableMultiValueRef emv = ABMultiValueCreateMutable(kABPersonEmailProperty);
    ABMultiValueAddValueAndLabel(emv, @"jsmith@example.com", kABOtherLabel, NULL);
    ABRecordSetValue(pref, kABPersonEmailProperty, emv, nil);

    // Load as MAVEABPerson record and test
    // record ID when not actually inserted in an address book is -1
    MAVEABPerson *p = [[MAVEABPerson alloc] initFromABRecordRef:pref];
    XCTAssertEqual(p.recordID, -1);
    XCTAssertEqualObjects(p.hashedRecordID, @"a54f0041a9e1");
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

- (void)testSettingRecordIDSetsHashedRecordID {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    // should default to hash of 0
    XCTAssertEqualObjects(p1.hashedRecordID, @"f1d3ff844329");

    p1.recordID = 1;
    // now it should equal the hash of 1
    XCTAssertEqualObjects(p1.hashedRecordID, @"f14503065176");
}

- (void)testToJSONDictionary {
    // With every value full
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.firstName = @"2"; p1.lastName = @"3";
    p1.phoneNumbers = @[@"18085551234"]; p1.phoneNumberLabels = @[@"_$!<Mobile>!$_"];
    p1.emailAddresses = @[@"foo@example.com"];

    NSDictionary *p1JSON = [p1 toJSONDictionary];
    XCTAssertEqualObjects([p1JSON objectForKey:@"record_id"], [NSNumber numberWithInteger:1]);
    XCTAssertEqualObjects([p1JSON objectForKey:@"hashed_record_id"], @"f14503065176");
    XCTAssertEqualObjects([p1JSON objectForKey:@"first_name"], @"2");
    XCTAssertEqualObjects([p1JSON objectForKey:@"last_name"], @"3");
    XCTAssertEqualObjects([p1JSON objectForKey:@"phone_numbers"], @[@"18085551234"]);
    XCTAssertEqualObjects([p1JSON objectForKey:@"phone_number_labels"], @[@"_$!<Mobile>!$_"]);
    XCTAssertEqualObjects([p1JSON objectForKey:@"email_addresses"], @[@"foo@example.com"]);
    NSData *p1Data = [NSJSONSerialization dataWithJSONObject:p1JSON options:0 error:nil];
    XCTAssertNotNil(p1Data);  // check that json serialization doesn't fail

    // with every value empty
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    NSDictionary *p2JSON = [p2 toJSONDictionary];
    XCTAssertEqualObjects([p2JSON objectForKey:@"record_id"], [NSNumber numberWithInteger:0]);
    XCTAssertEqualObjects([p2JSON objectForKey:@"first_name"], [NSNull null]);
    XCTAssertEqualObjects([p2JSON objectForKey:@"last_name"], [NSNull null]);
    XCTAssertEqualObjects([p2JSON objectForKey:@"phone_numbers"], @[]);
    XCTAssertEqualObjects([p2JSON objectForKey:@"phone_number_labels"], @[]);
    XCTAssertEqualObjects([p2JSON objectForKey:@"email_addresses"], @[]);
    NSData *p2Data = [NSJSONSerialization dataWithJSONObject:p2JSON options:0 error:nil];
    XCTAssertNotNil(p2Data);  // check that json serialization doesn't fail
}

- (void)testToJSONTupleArray {
    // With every value full
    NSString *hashedZero = @"00aa"; // TODO fix
    NSString *hashedOne = @"00aa";  // TODO fix
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.hashedRecordID = hashedOne;
    p1.firstName = @"2"; p1.lastName = @"3";
    p1.phoneNumbers = @[@"18085551234", @"18085554567"]; p1.phoneNumberLabels = @[@"_$!<Mobile>!$_", @"_$!<Main>!$_"];
    p1.emailAddresses = @[@"foo@example.com"];

    NSArray *p1JSON = [p1 toJSONTupleArray];
    NSArray *expected;
    expected = @[@"record_id", [NSNumber numberWithInteger:1]];
    XCTAssertEqualObjects([p1JSON objectAtIndex:0], expected);
    expected = @[@"hashed_record_id", hashedOne];
    XCTAssertEqualObjects([p1JSON objectAtIndex:1], expected);
    expected = @[@"first_name", @"2"];
    XCTAssertEqualObjects([p1JSON objectAtIndex:2], expected);
    expected = @[@"last_name", @"3"];
    XCTAssertEqualObjects([p1JSON objectAtIndex:3], expected);
    expected = @[@"phone_numbers", @[@"18085551234", @"18085554567"]];
    XCTAssertEqualObjects([p1JSON objectAtIndex:4], expected);
    expected = @[@"phone_number_labels", @[@"_$!<Mobile>!$_", @"_$!<Main>!$_"]];
    XCTAssertEqualObjects([p1JSON objectAtIndex:5], expected);
    expected = @[@"email_addresses", @[@"foo@example.com"]];
    XCTAssertEqualObjects([p1JSON objectAtIndex:6], expected);
    NSData *p1Data = [NSJSONSerialization dataWithJSONObject:p1JSON options:0 error:nil];
    XCTAssertNotNil(p1Data);  // check that json serialization doesn't fail

    // with every value empty
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.hashedRecordID = hashedZero;
    NSArray *p2JSON = [p2 toJSONTupleArray];
    expected = @[@"record_id", [NSNumber numberWithInteger:0]];
    XCTAssertEqualObjects([p2JSON objectAtIndex:0], expected);
    expected = @[@"hashed_record_id", hashedZero];
    XCTAssertEqualObjects([p2JSON objectAtIndex:1], expected);
    expected = @[@"first_name", [NSNull null]];
    XCTAssertEqualObjects([p2JSON objectAtIndex:2], expected);
    expected = @[@"last_name", [NSNull null]];
    XCTAssertEqualObjects([p2JSON objectAtIndex:3], expected);
    expected = @[@"phone_numbers", @[]];
    XCTAssertEqualObjects([p2JSON objectAtIndex:4], expected);
    expected = @[@"phone_number_labels", @[]];
    XCTAssertEqualObjects([p2JSON objectAtIndex:5], expected);
    expected = @[@"email_addresses", @[]];
    XCTAssertEqualObjects([p2JSON objectAtIndex:6], expected);
    NSData *p2Data = [NSJSONSerialization dataWithJSONObject:p2JSON options:0 error:nil];
    XCTAssertNotNil(p2Data);  // check that json serialization doesn't fail
}

- (void)testMerkleTreeSerializableFormIsTupleArray {
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    id mock = OCMPartialMock(p);
    id fakeObj = @[@4];
    OCMExpect([mock toJSONTupleArray]).andReturn(fakeObj);

    id output = [p merkleTreeSerializableData];
    XCTAssertEqualObjects(output, fakeObj);
    OCMVerifyAll(mock);
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

- (void)fakeCrashySetPhoneFromABRecordRef:(id)record {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:nil forKey:@"any key"];
}

- (void)testPhoneNumbersFromABRecordRefWhenTheUnexpectedHappens {
    // Swizzle the set phone numbers for the record method
    Method ogMethod = class_getInstanceMethod([MAVEABPerson class], @selector(setPhoneNumbersFromABRecordRef:));
    Method mockMethod = class_getInstanceMethod([self class], @selector(fakeCrashySetPhoneFromABRecordRef:));
    method_exchangeImplementations(ogMethod, mockMethod);

    ABRecordRef rec = [MAVEABTestDataFactory generateABRecordRef];
    MAVEABPerson *person = [[MAVEABPerson alloc] initFromABRecordRef:rec];
    // It will have crashed, check that we caught exception and just returned nil instead
    XCTAssertEqualObjects(person, nil);
    method_exchangeImplementations(mockMethod, ogMethod);
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
- (void)testInitRandomPersonWithName {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"Dan" lastName:@"Foo"];
    XCTAssertGreaterThan(p1.recordID, 0);
    XCTAssertEqualObjects(p1.firstName, @"Dan");
    XCTAssertEqualObjects(p1.lastName, @"Foo");
}
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

- (void)testMerkleTreeDataKey {
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    p.hashedRecordID = @"000000000000";
    XCTAssertEqual([p merkleTreeDataKey], 0);
    p.hashedRecordID = @"000000000001";
    XCTAssertEqual([p merkleTreeDataKey], 1);
    p.hashedRecordID = @"ffffffffffff";
    NSUInteger expected = (NSUInteger)(exp2(6*8) - 1);
    XCTAssertEqual([p merkleTreeDataKey], expected);
}

- (void)testComputeHashedRecordID {
    // Try a random number
    int32_t recordID = 123;
    XCTAssertEqualObjects([MAVEABPerson computeHashedRecordID:recordID], @"a7e0b18d0d45");
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

- (void)testCompareRecordIDs {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 100;
    MAVEABPerson *p2 =  [[MAVEABPerson alloc] init];
    p2.recordID = 101;
    XCTAssertEqual([p1 compareRecordIDs:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareRecordIDs:p1], NSOrderedDescending);

    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.recordID = 101;
    XCTAssertEqual([p2 compareRecordIDs:p3], NSOrderedSame);
    XCTAssertEqual([p3 compareRecordIDs:p2], NSOrderedSame);

    // Sorting them should work as expected, and be stable sort
    NSArray *people = @[p3, p2, p1];
    NSArray *sortedPeople = [people sortedArrayUsingSelector:@selector(compareRecordIDs:)];
    NSArray *expected = @[p1, p3, p2];
    XCTAssertEqualObjects(sortedPeople, expected);
}

- (void)testCompareHashedRecordIDs {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.hashedRecordID = @"000000000000";
    MAVEABPerson *p2 =  [[MAVEABPerson alloc] init];
    p2.hashedRecordID = @"ffffffffffff";
    XCTAssertEqual([p1 compareHashedRecordIDs:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareHashedRecordIDs:p1], NSOrderedDescending);

    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.hashedRecordID = @"ffffffffffff";
    XCTAssertEqual([p2 compareHashedRecordIDs:p3], NSOrderedSame);
    XCTAssertEqual([p3 compareHashedRecordIDs:p2], NSOrderedSame);

    // Sorting them should work as expected, and be stable sort
    NSArray *people = @[p3, p2, p1];
    NSArray *sortedPeople = [people sortedArrayUsingSelector:@selector(compareHashedRecordIDs:)];
    NSArray *expected = @[p1, p3, p2];
    XCTAssertEqualObjects(sortedPeople, expected);
}

@end