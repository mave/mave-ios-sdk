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

    XCTAssertEqual(p.numberFriendsOnApp, 0);
    XCTAssertFalse(p.isSuggestedContact);
    XCTAssertEqual(p.selected, NO);
    XCTAssertEqual(p.sendingStatus, MAVEInviteSendingStatusUnsent);

    // None of the contact identifiers should be selected, and test that the ranked lists are correctly filtering out phones/emails when they should
    XCTAssertEqual([p.allContactIdentifiers count], 2);
    NSArray *ranked = [p rankedContactIdentifiersIncludeEmails:YES includePhones:YES];
    XCTAssertEqual([ranked count], 2);
    MAVEContactPhoneNumber *phone0 = [ranked objectAtIndex:0];
    XCTAssertFalse(phone0.selected);
    MAVEContactEmail *email0 = [ranked objectAtIndex:1];
    XCTAssertFalse(email0.selected);
}

- (void)testSettingRecordIDSetsHashedRecordID {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    // should default to hash of 0
    XCTAssertEqual(p1.hashedRecordID, 17425552326754137906.0);

    p1.recordID = 1;
    // now it should equal the hash of 1
    XCTAssertEqual(p1.hashedRecordID, 17385305262205052069.0);
}

- (void)testSetSelected {
    // when setting the person's "selected" flag to true, if no contact identifiers are
    // selected under the person, set the top one to true
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:@"iPhone"];
    MAVEContactEmail *email = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p1.phoneObjects = @[phone];
    p1.emailObjects = @[email];
    p1.selected = NO;
    XCTAssertFalse(p1.selected);
    XCTAssertFalse(phone.selected);
    XCTAssertFalse(email.selected);

    p1.selected = YES;
    XCTAssertTrue(p1.selected);
    XCTAssertTrue(phone.selected);
    XCTAssertFalse(email.selected);

    p1.selected = NO;
    XCTAssertFalse(p1.selected);
    XCTAssertFalse(phone.selected);
    XCTAssertFalse(email.selected);
}

- (void)testUnselectPersonUnselectsAllContactIdentifiers {
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init];
    MAVEContactEmail *email00 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    MAVEContactEmail *email01 = [[MAVEContactEmail alloc] initWithValue:@"bar@gmail.com"];
    p0.emailObjects = @[email00, email01];

    p0.selected = YES;
    XCTAssertFalse(email00.selected);
    XCTAssertTrue(email01.selected);
    email00.selected = YES;

    p0.selected = NO;
    XCTAssertFalse(p0.selected);
    XCTAssertFalse(email00.selected);
    XCTAssertFalse(email01.selected);
}

- (void)testToJSONDictionary {
    // With every value full
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.firstName = @"2"; p1.lastName = @"3";
    p1.phoneNumbers = @[@"18085551234"]; p1.phoneNumberLabels = @[@"_$!<Mobile>!$_"];
    p1.emailAddresses = @[@"foo@example.com"];
    p1.isSuggestedContact = YES;
    p1.selectedFromSuggestions = YES;

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
    p1.isSuggestedContact = YES;

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

- (void)testToJSONDictionaryIncludingSuggestionsMetadata {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.isSuggestedContact = YES;
    p1.selectedFromSuggestions = YES;

    NSDictionary *d1 = [p1 toJSONDictionaryIncludingSuggestionsMetadata];
    XCTAssertTrue([[d1 valueForKey:@"is_suggested_contact"] boolValue]);
    XCTAssertTrue([[d1 valueForKey:@"selected_from_suggestions"] boolValue]);
    XCTAssertEqual([d1 count], 9);
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

- (void)testSetPhoneNumbersFromABRecordRef {
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

    // check the phone objects list as well
    XCTAssertEqual([p.phoneObjects count], 2);
    MAVEContactPhoneNumber *phone0 = [p.phoneObjects objectAtIndex:0];
    XCTAssertEqualObjects(phone0.value, @"+18085551234");
    XCTAssertEqualObjects([phone0 humanReadableLabel], @"cell");
    MAVEContactPhoneNumber *phone1 = [p.phoneObjects objectAtIndex:1];
    XCTAssertEqualObjects(phone1.value, @"+18085555678");
    XCTAssertEqualObjects([phone1 humanReadableLabel], @"main");
}

- (void)testSetPhoneNumbersFromABRecordRefWhenTheUnexpectedHappens {
    ABRecordRef rec = MAVECreateABRecordRef();

    MAVEABPerson *p1 = [MAVEABPerson alloc];
    id p1mock = OCMPartialMock(p1);
    NSException *exception = [[NSException alloc] init];
    [[[p1mock expect] initFromABRecordRef:rec] andThrow:exception];

    id obj = [p1 initFromABRecordRef:rec];
    XCTAssertNil(obj);  // should have raised an exception and not returned
    OCMVerifyAll(p1mock);
}

- (void)testSetPhoneNumbersFromABRecordRefNilLabel {
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

    XCTAssertEqual([p.phoneObjects count], 1);
    MAVEContactPhoneNumber *phone0 = [p.phoneObjects objectAtIndex:0];
    XCTAssertEqualObjects(phone0.value, @"+18085551234");
    XCTAssertEqualObjects([phone0 humanReadableLabel], @"other");
}

- (void)testSetPhoneNumbersFromABRecordRefWhenNone {
    ABRecordRef rec = ABPersonCreate();
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setPhoneNumbersFromABRecordRef:rec];
    XCTAssertEqual([p.phoneNumbers count], 0);
    XCTAssertEqual([p.phoneObjects count], 0);
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

    XCTAssertEqual([p.phoneObjects count], 1);
    MAVEContactPhoneNumber *phone0 = [p.phoneObjects objectAtIndex:0];
    XCTAssertEqualObjects(phone0.value, @"+18085551234");
    XCTAssertEqualObjects([phone0 humanReadableLabel], @"main");
}

- (void)testSetEmailAddressesFromABRecordRef {
    ABRecordRef rec = ABPersonCreate();
    ABMutableMultiValueRef emv = ABMultiValueCreateMutable(kABPersonEmailProperty);
    ABMultiValueAddValueAndLabel(emv, @"jsmith@example.com", kABOtherLabel, NULL);
    ABMultiValueAddValueAndLabel(emv, @"john.smith@example.com", kABOtherLabel, NULL);
    ABRecordSetValue(rec, kABPersonEmailProperty, emv, nil);

    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setEmailAddressesFromABRecordRef:rec];
    XCTAssertEqual([p.emailAddresses count], 2);
    XCTAssertEqualObjects(p.emailAddresses[0], @"jsmith@example.com");
    XCTAssertEqualObjects(p.emailAddresses[1], @"john.smith@example.com");

    // check the email objects list as well
    XCTAssertEqual([p.emailObjects count], 2);
    MAVEContactEmail *email0 = [p.emailObjects objectAtIndex:0];
    XCTAssertEqualObjects(email0.value, @"jsmith@example.com");
    MAVEContactEmail *email1 = [p.emailObjects objectAtIndex:1];    XCTAssertEqualObjects(email1.value, @"john.smith@example.com");
}

- (void)testEmailAddressesFromABRecordRefWhenNone {
    ABRecordRef rec = ABPersonCreate();
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    [p setEmailAddressesFromABRecordRef:rec];
    XCTAssertEqual([p.emailAddresses count], 0);
    XCTAssertEqual([p.emailObjects count], 0);
}

- (void)testInitFailsWhenBothNamesMissing {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] initFromABRecordRef:ABPersonCreate()];
    XCTAssertEqualObjects(p1, nil);
}

- (void)testInitFailsWhenNoPhoneOrEmail {
    ABRecordRef rec = ABPersonCreate();
    ABRecordSetValue(rec, kABPersonFirstNameProperty, @"John" , nil);
    MAVEABPerson *p1 = [[MAVEABPerson alloc] initFromABRecordRef:rec];
    XCTAssertEqualObjects(p1, nil);
}
- (void)testInitFailsWhenNoValidPhoneOrEmail {
    ABRecordRef rec = ABPersonCreate();
    ABRecordSetValue(rec, kABPersonFirstNameProperty, @"John" , nil);
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    // phone number is invalid b/c not 10 digits
    ABMultiValueAddValueAndLabel(pnmv, @"555.1234", kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    MAVEABPerson *p1 = [[MAVEABPerson alloc] initFromABRecordRef:rec];
    XCTAssertEqualObjects(p1, nil);
}

- (void)testInitWorksWhenEmailButNoPhone {
    ABRecordRef rec = ABPersonCreate();
    ABRecordSetValue(rec, kABPersonFirstNameProperty, @"John" , nil);
    ABMutableMultiValueRef emv = ABMultiValueCreateMutable(kABPersonEmailProperty);
    ABMultiValueAddValueAndLabel(emv, @"john@example.com", (CFStringRef)@"home", NULL);
    ABRecordSetValue(rec, kABPersonEmailProperty, emv, nil);
    MAVEABPerson *p1 = [[MAVEABPerson alloc] initFromABRecordRef:rec];
    XCTAssertNotNil(p1);
    XCTAssertEqual([p1.emailAddresses count], 1);
    XCTAssertEqual([p1.emailObjects count], 1);
}

- (void)testSelectedContactIdentifiersAndIsAtLeaseOneFunction {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:@"iPhone"];
    MAVEContactEmail *email = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p1.phoneObjects = @[phone];
    p1.emailObjects = @[email];
    XCTAssertEqual([[p1 rankedContactIdentifiersIncludeEmails:YES includePhones:YES] count], 2);
    XCTAssertEqual([[p1 selectedContactIdentifiers] count], 0);
    XCTAssertFalse([p1 isAtLeastOneContactIdentifierSelected]);
    phone.selected = YES;
    XCTAssertEqual([[p1 selectedContactIdentifiers] count], 1);
    XCTAssertTrue([p1 isAtLeastOneContactIdentifierSelected]);
    email.selected = YES;
    phone.selected = NO;
    XCTAssertEqual([[p1 selectedContactIdentifiers] count], 1);
    XCTAssertTrue([p1 isAtLeastOneContactIdentifierSelected]);
    email.selected = YES;
    phone.selected = YES;
    XCTAssertEqual([[p1 selectedContactIdentifiers] count], 2);
    XCTAssertTrue([p1 isAtLeastOneContactIdentifierSelected]);
    email.selected = NO;
    phone.selected = NO;
    XCTAssertEqual([[p1 selectedContactIdentifiers] count], 0);
    XCTAssertFalse([p1 isAtLeastOneContactIdentifierSelected]);
}

- (void)testRankedContactIdentifiers {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:@"other"];
    MAVEContactPhoneNumber *phone2 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085555678" andLabel:@"iPhone"];
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    MAVEContactEmail *email2 = [[MAVEContactEmail alloc] initWithValue:@"foo@gmail.com"];
    p1.phoneObjects = @[phone1, phone2];
    p1.emailObjects = @[email1, email2];

    NSArray *rankedAll = [p1 rankedContactIdentifiersIncludeEmails:YES includePhones:YES];
    XCTAssertEqual([rankedAll count], 4);
    XCTAssertEqualObjects(rankedAll[0], phone2);
    XCTAssertEqualObjects(rankedAll[1], phone1);
    XCTAssertEqualObjects(rankedAll[2], email2);
    XCTAssertEqualObjects(rankedAll[3], email1);

    NSArray *rankedPhones = [p1 rankedContactIdentifiersIncludeEmails:NO includePhones:YES];
    XCTAssertEqual([rankedPhones count], 2);
    XCTAssertEqualObjects(rankedPhones[0], phone2);
    XCTAssertEqualObjects(rankedPhones[1], phone1);

    NSArray *rankedEmails = [p1 rankedContactIdentifiersIncludeEmails:YES includePhones:NO];
    XCTAssertEqual([rankedEmails count], 2);
    XCTAssertEqualObjects(rankedEmails[0], email2);
    XCTAssertEqualObjects(rankedEmails[1], email1);

    XCTAssertEqual([[p1 rankedContactIdentifiersIncludeEmails:NO includePhones:NO] count], 0);
}

- (void)testSelectTopContactIdentifierIfNoneSelected {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:@"iPhone"];
    MAVEContactEmail *email = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p1.phoneObjects = @[phone];
    p1.emailObjects = @[email];
    email.selected = YES;
    // does nothing if one is already selected
    [p1 selectTopContactIdentifierIfNoneSelected];
    XCTAssertFalse(phone.selected);
    XCTAssertTrue(email.selected);

    phone.selected = NO;
    email.selected = NO;
    [p1 selectTopContactIdentifierIfNoneSelected];
    XCTAssertTrue(phone.selected);
    XCTAssertFalse(email.selected);
}

- (void)testContactIdentifierSelectedMethodsDontCrashWhenEmpty {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    XCTAssertFalse([p1 isAtLeastOneContactIdentifierSelected]);
    [p1 selectTopContactIdentifierIfNoneSelected];
    XCTAssertFalse([p1 isAtLeastOneContactIdentifierSelected]);
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
    MAVEABPerson *p5 = [[MAVEABPerson alloc] init];
    XCTAssertEqualObjects([p1 firstLetter], @"D");
    XCTAssertEqualObjects([p2 firstLetter], @"D");
    XCTAssertEqualObjects([p3 firstLetter], @"D");
    XCTAssertEqualObjects([p4 firstLetter], @"F");
    XCTAssertEqualObjects([p5 firstLetter], @"");
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

- (void)testInitials {
    MAVEABPerson *p0 = [MAVEABTestDataFactory personWithFirstName:nil lastName:nil];
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"Dan" lastName:nil];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:nil lastName:@"Foo"];
    MAVEABPerson *p3 = [MAVEABTestDataFactory personWithFirstName:@"Dan" lastName:@"Foo"];

    XCTAssertEqualObjects([p0 initials], @"");
    XCTAssertEqualObjects([p1 initials], @"D");
    XCTAssertEqualObjects([p2 initials], @"F");
    XCTAssertEqualObjects([p3 initials], @"DF");
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
    // We don't accept US numbers that aren't 10 digits
    // The library has weird behavior by sometimes stripping a leading 0, so we test for that too
    NSString *p1 = @"2.808.555.1234";
    NSString *p2 = @"08.555.1234";
    NSString *p3 = @"008-555-1234";
    NSString *p4 = @"867-5309";
    NSString *p5 = @"100";
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p1], @"+128085551234");
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p2], nil);
    XCTAssertEqualObjects([MAVEABPerson normalizePhoneNumber:p3], nil);
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
