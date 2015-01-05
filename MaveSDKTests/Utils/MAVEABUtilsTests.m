//
//  MAVEABUtilsTests.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
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
    NSArray *addressBook = [MAVEABTestDataFactory generateAddressBookOfSize:3];
    NSString *firstName = CFBridgingRelease(
                                            ABRecordCopyValue((__bridge ABRecordRef)addressBook[0], kABPersonFirstNameProperty));
    XCTAssertNotEqualObjects(firstName, nil);
    
    NSArray *formattedAB = [MAVEABUtils copyEntireAddressBookToMAVEABPersonArray:addressBook];
    XCTAssertEqual([formattedAB count], 3);
    NSSet *firstNames = [[NSSet alloc] initWithObjects:
            ((MAVEABPerson *)formattedAB[0]).firstName,
            ((MAVEABPerson *)formattedAB[1]).firstName,
            ((MAVEABPerson *)formattedAB[2]).firstName, nil];
    XCTAssertEqual([firstNames containsObject:firstName], YES);
    // TODO Assert that the sort function was called
}

- (void)testIndexedDictionaryOfMAVEABPersons {
    MAVEABPerson *p1 = [MAVEABTestDataFactory personWithFirstName:@"Don" lastName:@"Adams"];
    MAVEABPerson *p2 = [MAVEABTestDataFactory personWithFirstName:@"Deb" lastName:@"Anderson"];
    MAVEABPerson *p3 = [MAVEABTestDataFactory personWithFirstName:@"Foo" lastName:@"Bernard"];
    NSArray *data = @[p1, p2, p3];
    NSDictionary *expected = @{@"D": @[p1, p2], @"F": @[p3]};

    NSDictionary *indexed = [MAVEABUtils indexedDictionaryFromMAVEABPersonArray:data];
    XCTAssertEqualObjects(indexed, expected);
}

- (void)testIndexedDictionaryOfMAVEABPersonsAcceptsNilAndEmpty {
    NSArray *data = nil;
    XCTAssertNil([MAVEABUtils indexedDictionaryFromMAVEABPersonArray:data]);
    
    data = @[];
    XCTAssertNil([MAVEABUtils indexedDictionaryFromMAVEABPersonArray:data]);
}

@end
