//
//  MAVEABUtilsTests.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MAVEABUtils.h"
#import "MAVEABTestDataFactory.h"

@interface MAVEABUtilsTests : XCTestCase

@end

@implementation MAVEABUtilsTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddressBookPermissionStatus {
    // Don't want to make the tests dependent on a particular status,
    // so just test status is one of our defined string constants.
    NSString *status = [MAVEABUtils addressBookPermissionStatus];
    XCTAssertTrue(status == MAVEABPermissionStatusAllowed ||
                  status == MAVEABPermissionStatusDenied ||
                  status == MAVEABPermissionStatusUnprompted);
}

- (void) testSortMAVEABPersonArray {
    NSMutableArray *ab = [[NSMutableArray alloc] init];
    MAVEABPerson *p1 = nil;
    [ab addObject:[MAVEABTestDataFactory personWithFirstName:@"A" lastName:@"B"]];
    [ab addObject:[MAVEABTestDataFactory personWithFirstName:@"A" lastName:@"A"]];
    
    p1 = ab[0];
    XCTAssertEqualObjects(p1.lastName, @"B");
    [MAVEABUtils sortMAVEABPersonArray:ab];
    p1 = ab[0];
    XCTAssertEqualObjects(p1.lastName, @"A");
}

- (void) testCopyEntireAddressBookToMAVEABPersonArray {
    ABRecordRef rec0 = MAVECreateABRecordRef();
    ABRecordRef rec1 = MAVECreateABRecordRef();
    ABRecordRef rec2 = MAVECreateABRecordRef();
    id rec0Arc = (__bridge id)rec0;
    NSArray *addressBook = @[rec0Arc, (__bridge id)rec1, (__bridge id)rec2];

    CFStringRef firstNameCF = ABRecordCopyValue(rec0, kABPersonFirstNameProperty);
    NSString *firstName = CFBridgingRelease(firstNameCF);
    XCTAssertNotEqualObjects(firstName, nil);
    
    NSArray *formattedAB = [MAVEABUtils copyEntireAddressBookToMAVEABPersonArray:addressBook];
    XCTAssertEqual([formattedAB count], 3);
    NSSet *firstNames = [[NSSet alloc] initWithObjects:
            ((MAVEABPerson *)formattedAB[0]).firstName,
            ((MAVEABPerson *)formattedAB[1]).firstName,
            ((MAVEABPerson *)formattedAB[2]).firstName, nil];
    XCTAssertEqual([firstNames containsObject:firstName], YES);

    // assert that it's sorted
    NSMutableArray *resortedFormattedAB = [[NSMutableArray alloc] initWithArray:formattedAB];
    [MAVEABUtils sortMAVEABPersonArray:resortedFormattedAB];
    XCTAssertEqualObjects(resortedFormattedAB, formattedAB);
}

- (NSArray *)_simpleAddressBookToTestFilter {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"HasBoth" lastName:@"Adams"];
    p1.phoneNumbers = @[@"+18085551234"];
    p1.emailAddresses = @[@"adams@example.com"];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:@"NoPhone" lastName:@"Anderson"];
    p2.emailAddresses = @[@"andy@example.com"];
    MAVEABPerson *p3 = [MAVEABTestDataFactory personWithFirstName:@"NoEmail" lastName:@"Bernard"];
    p3.phoneNumbers = @[@"+18085555678"];
    return @[p1, p2, p3];
}

- (void)testFilterAddressBookRemoveIfMissingPhone {
    NSArray *addressBook = [self _simpleAddressBookToTestFilter];
    NSArray *new = [MAVEABUtils filterAddressBook:addressBook removeIfMissingPhones:YES removeIfMissingEmails:NO];
    XCTAssertEqual([new count], 2);
    MAVEABPerson *p1 = [new objectAtIndex:0];
    XCTAssertEqualObjects(p1.firstName, @"HasBoth");
    MAVEABPerson *p3 = [new objectAtIndex:1];
    XCTAssertEqualObjects(p3.firstName, @"NoEmail");
}

- (void)testFilterAddressBookRemoveIfMissingEmail {
    NSArray *addressBook = [self _simpleAddressBookToTestFilter];
    NSArray *new = [MAVEABUtils filterAddressBook:addressBook removeIfMissingPhones:NO removeIfMissingEmails:YES];
    XCTAssertEqual([new count], 2);
    MAVEABPerson *p1 = [new objectAtIndex:0];
    XCTAssertEqualObjects(p1.firstName, @"HasBoth");
    MAVEABPerson *p2 = [new objectAtIndex:1];
    XCTAssertEqualObjects(p2.firstName, @"NoPhone");
}

- (void)testFilterAddressBookRemoveIfMissingPhoneOrEmail {
    NSArray *addressBook = [self _simpleAddressBookToTestFilter];
    NSArray *new = [MAVEABUtils filterAddressBook:addressBook removeIfMissingPhones:YES removeIfMissingEmails:YES];
    XCTAssertEqual([new count], 1);
    MAVEABPerson *p1 = [new objectAtIndex:0];
    XCTAssertEqualObjects(p1.firstName, @"HasBoth");
}

- (void)testFilterAddressBookNoFilters {
    NSArray *addressBook = [self _simpleAddressBookToTestFilter];
    NSArray *new = [MAVEABUtils filterAddressBook:addressBook removeIfMissingPhones:NO removeIfMissingEmails:NO];
    XCTAssertEqual([new count], 3);
    MAVEABPerson *p1 = [new objectAtIndex:0];
    XCTAssertEqualObjects(p1.firstName, @"HasBoth");
    MAVEABPerson *p2 = [new objectAtIndex:1];
    XCTAssertEqualObjects(p2.firstName, @"NoPhone");
    MAVEABPerson *p3 = [new objectAtIndex:2];
    XCTAssertEqualObjects(p3.firstName, @"NoEmail");
}

- (void)testFilterAddressBookDoesntBreakForNilAndEmpty {
    NSArray *new = [MAVEABUtils filterAddressBook:nil removeIfMissingPhones:YES removeIfMissingEmails:YES];
    XCTAssertNil(new);

    NSArray *new2 = [MAVEABUtils filterAddressBook:@[] removeIfMissingPhones:YES removeIfMissingEmails:YES];
    XCTAssertEqualObjects(new2, @[]);
}

- (void)testIndexABPersonArrayForTableSections {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"Don" lastName:@"Adams"];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:@"Deb" lastName:@"Anderson"];
    MAVEABPerson *p3 = [MAVEABTestDataFactory personWithFirstName:@"Foo" lastName:@"Bernard"];
    NSArray *data = @[p1, p2, p3];
    NSDictionary *expected = @{@"D": @[p1, p2], @"F": @[p3]};

    NSDictionary *indexed = [MAVEABUtils indexABPersonArrayForTableSections:data];
    XCTAssertEqualObjects(indexed, expected);
}

- (void)testIndexABPersonArrayForTableSectionsAcceptsNilAndEmpty {
    NSArray *data = nil;
    XCTAssertNil([MAVEABUtils indexABPersonArrayForTableSections:data]);
    
    data = @[];
    XCTAssertNil([MAVEABUtils indexABPersonArrayForTableSections:data]);
}

- (void)testListOfABPersonsFromListOfHashedRecordIDTuples {
    // make some people and explicitly overwrite hashed record id so we know it
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.hashedRecordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.hashedRecordID = 1;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.hashedRecordID = 2;
    NSArray *contacts = @[p0, p1, p2];

    // The tuple format is (hashed record id, number connections).
    // The second parameter is not used for now but is an integer score of how close the connection is,
    // higher is better
    NSArray *hashedRecordIDs = @[@[@"0", @10], @[@"2", @2]];
    NSArray *suggested = [MAVEABUtils listOfABPersonsFromListOfHashedRecordIDTuples:hashedRecordIDs andAllContacts:contacts];
    NSArray *expectedSuggested = @[p0, p2];
    XCTAssertEqualObjects(suggested, expectedSuggested);
}

- (void)testListOfABPersonsFromHashedRecordIDTuplesIgnoresBadInputData {
    // if one of the list items is not a 2-tuple, should be ignored
    // make some people and explicitly overwrite hashed record id so we know it
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.hashedRecordID = 0;
    NSArray *contacts = @[p0];

    // Data - 0 and 1 are the HRID's there, but only 0 exists so that should be only suggested
    NSArray *evilNullTuple = (NSArray *)[NSNull null];
    NSArray *hashedRecordIDs = @[@1, @[@"0", @10], @[@"1", @5], @[], evilNullTuple];
    NSArray *suggested = [MAVEABUtils listOfABPersonsFromListOfHashedRecordIDTuples:hashedRecordIDs andAllContacts:contacts];
    NSArray *expectedSuggested = @[p0];
    XCTAssertEqualObjects(suggested, expectedSuggested);
}

- (void)testInstancesofABPersonsInListFromAllContacts {
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.hashedRecordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.hashedRecordID = 1;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.hashedRecordID = 2;
    MAVEABPerson *p1r = [[MAVEABPerson alloc] init]; p1r.hashedRecordID = 1;
    MAVEABPerson *p3r = [[MAVEABPerson alloc] init]; p3r.hashedRecordID = 3;
    NSArray *contacts = @[p0, p1, p2];
    // p3 doesn't exist in contacts so it should get filtered out for now
    NSArray *list = @[p1r, p3r];
    XCTAssertEqual(p1, p1);
    XCTAssertNotEqual(p1, p1r);

    NSArray *results = [MAVEABUtils instancesOfABPersonsInList:list fromAllContacts:contacts];
    XCTAssertEqual([results count], 1);
    MAVEABPerson *result1 = [results objectAtIndex:0];
    XCTAssertEqual(result1, p1);
}

- (void)testIndexABPersonArrayByHashedRecordID {
    // make some people and explicitly overwrite hashed record id so we know it
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.hashedRecordID = 0;
    uint64_t biggestValue = 1844674407370955161 * 10 + 5;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.hashedRecordID = biggestValue;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.hashedRecordID = 2;
    // if there happens to be a hashed record id collision, it simply uses the
    // last one in the list. This should never happen due to md5 being
    // evenly distributed and size of uint64_t
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init]; p3.hashedRecordID = 2;
    NSArray *contacts = @[p0, p1, p2, p3];

    NSDictionary *indexed = [MAVEABUtils indexABPersonArrayByHashedRecordID:contacts];
    XCTAssertEqual([indexed count], 3);
    XCTAssertEqualObjects([indexed objectForKey:@"0"], p0);
    XCTAssertEqualObjects([indexed objectForKey:@"18446744073709551615"], p1);
    XCTAssertNotEqualObjects([indexed objectForKey:@"2"], p2);
    XCTAssertEqualObjects([indexed objectForKey:@"2"], p3);
}

- (void)testCombineSuggestedIntoABIndexedForTableSections {
    // build an indexed addres book
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.firstName = @"Aalbert";
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.firstName = @"Andy";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.firstName = @"Beverly";
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init]; p3.firstName = @"Carly";
    MAVEABPerson *p4 = [[MAVEABPerson alloc] init]; p4.firstName = @"Clara";
    NSDictionary *tableData = @{
        @"A": @[p0, p1],
        @"B": @[p2],
        @"C": @[p3, p4],
        };

    // Also build a list of suggested people. Note there is some overlap but also one
    // contact not found in address book (this may be impossible depending on implementation
    // of suggested but may as well support it from a data model perspective).
    MAVEABPerson *p5 = [[MAVEABPerson alloc] init]; p5.firstName = @"Suggested 1";
    NSArray *suggested = @[p5, p0, p1];

    // Define what the expected data should be.
    // Note we don't take people out of the data just because they are in suggested
    NSDictionary *expectedTableData = @{
        @"\u2605": @[p5, p0, p1],
        @"A": @[p0, p1],
        @"B": @[p2],
        @"C": @[p3, p4],
    };

    NSDictionary *newTableData = [MAVEABUtils combineSuggested:suggested
                                 intoABIndexedForTableSections:tableData];

    XCTAssertEqualObjects(newTableData, expectedTableData);
}

@end
