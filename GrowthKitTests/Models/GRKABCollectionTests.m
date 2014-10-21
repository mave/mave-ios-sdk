//
//  AddressBookDataTests.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GRKABCollection.h"
#import "GRKABCollection_Internal.h"
#import "GRKABTestDataFactory.h"

@interface GRKABCollectionTests : XCTestCase

@end

@implementation GRKABCollectionTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testSortGRKABPersonArray {
    NSMutableArray *ab = [[NSMutableArray alloc] init];
    GRKABPerson *p1 = nil;
    [ab addObject:[GRKABTestDataFactory personWithFirstName:@"A" lastName:@"B"]];
    [ab addObject:[GRKABTestDataFactory personWithFirstName:@"A" lastName:@"A"]];
    
    p1 = ab[0];
    XCTAssertEqualObjects(p1.lastName, @"B");
    [GRKABCollection sortGRKABPersonArray:ab];
    p1 = ab[0];
    XCTAssertEqualObjects(p1.lastName, @"A");
}

- (void) testCopyEntireAddressBookToGRKABPersonArray {
    NSArray *addressBook = [GRKABTestDataFactory generateAddressBookOfSize:3];
    NSString *firstName = CFBridgingRelease(
                                            ABRecordCopyValue((__bridge ABRecordRef)addressBook[0], kABPersonFirstNameProperty));
    XCTAssertNotEqualObjects(firstName, nil);
    
    NSArray *formattedAB = [GRKABCollection copyEntireAddressBookToGRKABPersonArray:addressBook];
    XCTAssertEqual([formattedAB count], 3);
    NSSet *firstNames = [[NSSet alloc] initWithObjects:
            ((GRKABPerson *)formattedAB[0]).firstName,
            ((GRKABPerson *)formattedAB[1]).firstName,
            ((GRKABPerson *)formattedAB[2]).firstName, nil];
    XCTAssertEqual([firstNames containsObject:firstName], YES);
    // TODO Assert that the sort function was called
}

- (void)testIndexedDictionaryOfGRKABPersons {
    GRKABCollection *ab = [[GRKABCollection alloc] init];
    GRKABPerson *p1 = [GRKABTestDataFactory personWithFirstName:@"Don" lastName:@"Adams"];
    GRKABPerson *p2 = [GRKABTestDataFactory personWithFirstName:@"Deb" lastName:@"Anderson"];
    GRKABPerson *p3 = [GRKABTestDataFactory personWithFirstName:@"Foo" lastName:@"Bernard"];
    ab.data = @[p1, p2, p3];
    NSDictionary *expected = @{@"D": @[p1, p2], @"F": @[p3]};

    NSDictionary *indexed = [ab indexedDictionaryOfGRKABPersons];
    XCTAssertEqualObjects(indexed, expected);
}

- (void)testIndexedDictionaryOfGRKABPersonsAcceptsNilAndEmpty {
    GRKABCollection *ab = [[GRKABCollection alloc] init];
    ab.data = nil;
    XCTAssertEqualObjects([ab indexedDictionaryOfGRKABPersons], nil);
    
    ab.data = @[];
    XCTAssertEqualObjects([ab indexedDictionaryOfGRKABPersons], nil);
}

@end
