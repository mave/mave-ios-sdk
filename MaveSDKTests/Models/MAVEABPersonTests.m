//
//  MAVEABPersonTests.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <OCMock/OCMock.h>
#import <AddressBook/AddressBook.h>
#import "MAVEABPerson.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVEABTestDataFactory.h"
#import "MAVEMerkleTreeHashUtils.h"
#import "Gizou.h"


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
    XCTAssertEqual(p.hashedRecordID, 11911739821441243909.0);
    XCTAssertEqualObjects(p.firstName, @"John");
    XCTAssertEqualObjects(p.lastName, @"Smith");
    XCTAssertEqual([p.phoneNumbers count], 1);
    // Should have converted number to default format
    XCTAssertEqualObjects(p.phoneNumbers[0], @"+18085551234");
    XCTAssertEqual([p.phoneNumberLabels count], 1);
    XCTAssertEqualObjects(p.phoneNumberLabels[0], @"_$!<Mobile>!$_");
    
    XCTAssertEqual([p.emailAddresses count], 1);
    XCTAssertEqualObjects(p.emailAddresses[0], @"jsmith@example.com");
    XCTAssertEqual(p.selected, NO);
}

- (void)testSettingRecordIDSetsHashedRecordID {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    // should default to hash of 0
    XCTAssertEqual(p1.hashedRecordID, 17425552326754137906.0);

    p1.recordID = 1;
    // now it should equal the hash of 1
    XCTAssertEqual(p1.hashedRecordID, 17385305262205052069.0);
}

- (void)testToJSONDictionary {
    // With every value full
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.firstName = @"2"; p1.lastName = @"3";
    p1.phoneNumbers = @[@"18085551234"]; p1.phoneNumberLabels = @[@"_$!<Mobile>!$_"];
    p1.emailAddresses = @[@"foo@example.com"];

    NSDictionary *p1JSON = [p1 toJSONDictionary];
    XCTAssertEqualObjects([p1JSON objectForKey:@"record_id"], [NSNumber numberWithInteger:1]);
    // weird gymnasics to avoid the "constant is larger than largest signed int" compiler warnings
    // which occur even though I'm assigning to an unsigned 64-bit integer
    uint64_t expectedHashedRecordID = 1738530526220505206 * 10 + 9;
    XCTAssertEqualObjects([p1JSON objectForKey:@"hashed_record_id"],
                          @(expectedHashedRecordID));
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
    uint64_t hashedOne = 1738530526220505206 * 10 + 9;
    uint64_t hashedZero = 1742555232675413790 * 10 + 6;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.hashedRecordID = hashedOne;
    p1.firstName = @"2"; p1.lastName = @"3";
    p1.phoneNumbers = @[@"18085551234", @"18085554567"]; p1.phoneNumberLabels = @[@"_$!<Mobile>!$_", @"_$!<Main>!$_"];
    p1.emailAddresses = @[@"foo@example.com"];

    NSArray *p1JSON = [p1 toJSONTupleArray];
    NSArray *expected;
    expected = @[@"record_id", [NSNumber numberWithInteger:1]];
    XCTAssertEqualObjects([p1JSON objectAtIndex:0], expected);
    expected = @[@"hashed_record_id", @(hashedOne)];
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
    expected = @[@"hashed_record_id", @(hashedZero)];
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
    XCTAssertEqualObjects(p.phoneNumbers[0], @"+18085551234");
    XCTAssertEqualObjects(p.phoneNumberLabels[0], @"_$!<Mobile>!$_");
    XCTAssertEqualObjects(p.phoneNumbers[1], @"+18085555678");
    XCTAssertEqualObjects(p.phoneNumberLabels[1], @"_$!<Main>!$_");
}

- (void)testPhoneNumbersFromABRecordRefWhenTheUnexpectedHappens {
    ABRecordRef rec = MAVECreateABRecordRef();

    MAVEABPerson *p1 = [MAVEABPerson alloc];
    id p1mock = OCMPartialMock(p1);
    NSException *exception = [[NSException alloc] init];
    [[[p1mock expect] initFromABRecordRef:rec] andThrow:exception];

    id obj = [p1 initFromABRecordRef:rec];
    XCTAssertNil(obj);  // should have raised an exception and not returned
    OCMVerifyAll(p1mock);
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
    XCTAssertEqualObjects(p.phoneNumbers[0], @"+18085551234");
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
    XCTAssertEqualObjects(p.phoneNumbers[0], @"+18085551234");
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
    XCTAssertEqualObjects([p bestPhone], @"+18085551234");
}

- (void)testBestPhonePreferMainIfNoMobile {
    ABRecordRef rec = ABPersonCreate();
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, @"(808) 555- 5678", kABPersonPhoneHomeFAXLabel, NULL);
    ABMultiValueAddValueAndLabel(pnmv, @"808.555.1234", kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqualObjects([p bestPhone], @"+18085551234");
}

#pragma mark - Normalize Phone Numbers

- (void)testNormalizePhoneBasicFormats {
    // These tests assume the device region is US
    XCTAssertEqualObjects([MAVEClientPropertyUtils countryCode], @"US");
    NSString *p1 = @"(808) 555-1234";
    NSString *p2 = @"808.555.1234";
    NSString *p3 = @"808-555-1234";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], @"+18085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p2], @"+18085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p3], @"+18085551234");
    // try some from the GZ library
    NSString *p, *pNormalized;
    for (int i = 0; i < 10; ++i) {
        p = [GZPhoneNumbers phoneNumber];
        pNormalized = [MAVEABPerson normalizePhoneNumber:p];
        XCTAssertNotNil(pNormalized);
    }
}

- (void) testNormalizePhoneIfAlreadyContains1 {
    NSString *p1 = @"+1 (808) 555-1234";
    NSString *p2 = @"+1.808.555.1234";
    NSString *p3 = @"1.808.555.1234";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], @"+18085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p2], @"+18085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p3], @"+18085551234");
}

- (void)testFilterUSPhoneNumbersWithBadAreaCodes {
    // We still accept US numbers that aren't 10 digits, but we don't accept 7 digits or shorter.
    // The library has weird behavior by sometimes stripping a leading 0, so we test for that too
    NSString *p1 = @"2.808.555.1234";
    NSString *p2 = @"08.555.1234";
    NSString *p3 = @"008-555-1234";
    NSString *p4 = @"867-5309";
    NSString *p5 = @"100";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], @"+128085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p2], @"+1085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p3], @"+1085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p4], nil);
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p5], nil);
}

- (void)testNormalizeInvalidPhonesReturnNil {
    // non digit or too short numbers return nil
    NSString *p1 = @"notanumber";
    NSString *p2 = nil;
    NSString *p3 = @"10";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], nil);
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p2], nil);
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p3], nil);
}

- (void)testNormalizeNonUSPhoneNumbers {
    // try a barcelona phone number
    id clientPropertiesMock = OCMClassMock([MAVEClientPropertyUtils class]);
    OCMStub([clientPropertiesMock countryCode]).andReturn(@"ES");
    NSString *p1 = @"93 4027000";
    NSString *p2 = @"+34 93 4027000";
    // This one is really short, but we're not specifying a minimum area code
    NSString *p3 = @"1234";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], @"+34934027000");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p2], @"+34934027000");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p3], @"+341234");
}

- (void)testFallbackCountryCodeIsUS {
    id clientPropertiesMock = OCMClassMock([MAVEClientPropertyUtils class]);
    OCMExpect([clientPropertiesMock countryCode]).andReturn(nil);
    NSString *p1 = @"8085551234";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], @"+18085551234");
    OCMVerifyAll(clientPropertiesMock);
}

- (void)testDisplayPhoneNumberSuccess {
    NSString *p1 = @"+18085551234";
    XCTAssertEqualObjects([MAVEABPerson displayPhoneNumber:p1],
                          @"(808)\u00a0555-1234");
    // Barcelona phone number
    NSString *p2 = @"+34934027000";
    XCTAssertEqualObjects([MAVEABPerson displayPhoneNumber:p2],
                          @"+34\u00a0934\u00a002\u00a070\u00a000");
    // if an invalid phone number somehow snuck in, just return it
    NSString *p3 = @"234";
    XCTAssertEqualObjects([MAVEABPerson displayPhoneNumber:p3], @"234");
}

- (void)testDisplayPhoneNumberWhenPhoneInternational {
    id clientPropertiesMock = OCMClassMock([MAVEClientPropertyUtils class]);
    OCMStub([clientPropertiesMock countryCode]).andReturn(@"ES");
    NSString *p1 = @"+18085551234";
    XCTAssertEqualObjects([MAVEABPerson displayPhoneNumber:p1],
                          @"+1\u00a0808-555-1234");

    NSString *p2 = @"+34934027000";
    XCTAssertEqualObjects([MAVEABPerson displayPhoneNumber:p2],
                          @"934\u00a002\u00a070\u00a000");
}

- (void)testMerkleTreeDataKey {
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    p.hashedRecordID = 0;
    XCTAssertEqual([p merkleTreeDataKey], 0);
    p.hashedRecordID = 1;
    XCTAssertEqual([p merkleTreeDataKey], 1);
    p.hashedRecordID = NSUIntegerMax;
    XCTAssertEqual([p merkleTreeDataKey], NSUIntegerMax);
}

- (void)testComputeHashedRecordID {
    // Try a random number
    XCTAssertEqual([MAVEABPerson computeHashedRecordID:123], 12096863818488289003.0);
    // Try min and max values
    XCTAssertEqual([MAVEABPerson computeHashedRecordID:0], 17425552326754137906.0);
    uint32_t maxPositiveInt32 = (uint32_t)(exp2(31)-1);
    XCTAssertEqual([MAVEABPerson computeHashedRecordID:maxPositiveInt32], 3983850407624765731.0);
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
    p1.hashedRecordID = 0;
    MAVEABPerson *p2 =  [[MAVEABPerson alloc] init];
    p2.hashedRecordID = NSUIntegerMax;
    XCTAssertEqual([p1 compareHashedRecordIDs:p2], NSOrderedAscending);
    XCTAssertEqual([p2 compareHashedRecordIDs:p1], NSOrderedDescending);

    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.hashedRecordID = NSUIntegerMax;
    XCTAssertEqual([p2 compareHashedRecordIDs:p3], NSOrderedSame);
    XCTAssertEqual([p3 compareHashedRecordIDs:p2], NSOrderedSame);

    // Sorting them should work as expected, and be stable sort
    NSArray *people = @[p3, p2, p1];
    NSArray *sortedPeople = [people sortedArrayUsingSelector:@selector(compareHashedRecordIDs:)];
    NSArray *expected = @[p1, p3, p2];
    XCTAssertEqualObjects(sortedPeople, expected);
}

@end
