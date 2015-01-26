//
//  MAVEABSyncManagerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEABSyncManager.h"
#import "MAVEABPErson.h"
#import "MAVECompressionUtils.h"
#import "MaveSDK.h"
#import "MAVEAPIInterface.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEABSyncManagerTests : XCTestCase

@end

@implementation MAVEABSyncManagerTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSerializeAndCompress {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.firstName = @"Danny"; p1.lastName = @"Cosson";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.recordID = 2; p2.firstName = @"Foo"; p2.lastName = @"Bar";
    NSArray *addressBook = @[p2, p1];
    MAVEABSyncManager *manager = [[MAVEABSyncManager alloc] initWithAddressBookData:addressBook];
    NSArray *expectedAB = @[p2, p1];  // won't be sorted yet on init
    XCTAssertEqualObjects(manager.addressBook, expectedAB);
    NSData *output = [manager serializeAndCompressAddressBook];
    XCTAssertNotNil(output);

    // now decode and make sure it's the same array we expect
    NSArray *returnedAddressBook = [NSJSONSerialization JSONObjectWithData:[MAVECompressionUtils gzipUncompressData:output] options:0 error:nil];
    XCTAssertEqual([returnedAddressBook count], 2);
    NSDictionary *obj1 = [returnedAddressBook objectAtIndex:0];
    XCTAssertEqual(((NSNumber *)[obj1 objectForKey:@"record_id"]).integerValue, 1);
    XCTAssertEqualObjects([obj1 objectForKey:@"first_name"], @"Danny");
    XCTAssertEqualObjects([obj1 objectForKey:@"last_name"], @"Cosson");

    NSDictionary *obj2 = [returnedAddressBook objectAtIndex:1];
    XCTAssertEqual(((NSNumber *)[obj2 objectForKey:@"record_id"]).integerValue, 2);
    XCTAssertEqualObjects([obj2 objectForKey:@"first_name"], @"Foo");
    XCTAssertEqualObjects([obj2 objectForKey:@"last_name"], @"Bar");
}

- (void)testSendContactsToServer {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id syncerMock = OCMPartialMock(syncer);
    id apiMock = OCMClassMock([MAVEAPIInterface class]);
    [MaveSDK sharedInstance].APIInterface = apiMock;

    OCMExpect([syncerMock serializeAndCompressAddressBook]);
    OCMExpect([apiMock sendIdentifiedDataWithRoute:@"/address_book_upload" methodName:@"PUT" data:[OCMArg any]]);

    [syncer sendContactsToServer];

    OCMVerifyAll(syncerMock);
    OCMVerifyAll(apiMock);
}

- (void)testGroupContactsForMerkletree {
    // Use a tree height of 3, so 2^2 = 4 buckets
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 9;  // hashes to bucket 1
    XCTAssertEqual(p1.hashedRecordID, 1027473925);
    p1.firstName = @"Foo"; p1.lastName = @"Barl";
    p1.emailAddresses = @[@"foo@example.com"];
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.recordID = 15; // hashes to bucket 1, less than hash of p1
    XCTAssertEqual(p2.hashedRecordID, 775595069);
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.recordID = 3;  // hashes to bucket 2
    XCTAssertEqual(p3.hashedRecordID, 1481250217);
    MAVEABPerson *p4 = [[MAVEABPerson alloc] init];
    p4.recordID = 5;  // hashes to bucket 3
    XCTAssertEqual(p4.hashedRecordID, 3141434063);
    MAVEABPerson *p5 = [[MAVEABPerson alloc] init];
    p5.recordID = 1;  // hashes to bucket 4
    XCTAssertEqual(p5.hashedRecordID, 4047831814);

    NSArray *addressBook = @[p1, p5, p4, p2, p3];
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] initWithAddressBookData:addressBook];

    NSArray *array = [syncer groupContactsForMerkleTreeWithHeight:3];
    NSArray *person, *expectedTuple;
    XCTAssertEqual([array count], 4);

    // p1
    XCTAssertEqual([[array objectAtIndex:0] count], 2);
    person = [[array objectAtIndex:0] objectAtIndex:1];
    expectedTuple = @[@"record_id", [NSNumber numberWithInteger:p1.recordID]];
    XCTAssertEqualObjects([person objectAtIndex:0], expectedTuple);
    expectedTuple = @[@"first_name", @"Foo"];
    XCTAssertEqualObjects([person objectAtIndex:1], expectedTuple);
    expectedTuple = @[@"last_name", @"Barl"];
    XCTAssertEqualObjects([person objectAtIndex:2], expectedTuple);
    expectedTuple = @[@"email_addresses", @[@"foo@example.com"]];
    XCTAssertEqualObjects([person objectAtIndex:5], expectedTuple);

    // p2
    person = [[array objectAtIndex:0] objectAtIndex:0];
    expectedTuple = @[@"record_id", [NSNumber numberWithInteger:p2.recordID]];
    XCTAssertEqualObjects([person objectAtIndex:0], expectedTuple);

    // p3
    XCTAssertEqual([[array objectAtIndex:1] count], 1);
    person = [[array objectAtIndex:1] objectAtIndex:0];
    expectedTuple = @[@"record_id", [NSNumber numberWithInteger:p3.recordID]];
    XCTAssertEqualObjects([person objectAtIndex:0], expectedTuple);

    // p4
    XCTAssertEqual([[array objectAtIndex:2] count], 1);
    person = [[array objectAtIndex:2] objectAtIndex:0];
    expectedTuple = @[@"record_id", [NSNumber numberWithInteger:p4.recordID]];
    XCTAssertEqualObjects([person objectAtIndex:0], expectedTuple);

    // p5
    XCTAssertEqual([[array objectAtIndex:3] count], 1);
    person = [[array objectAtIndex:3] objectAtIndex:0];
    expectedTuple = @[@"record_id", [NSNumber numberWithInteger:p5.recordID]];
    XCTAssertEqualObjects([person objectAtIndex:0], expectedTuple);
}

- (void)testEmptyCaseGroupContactsForMerkleTree {
    NSArray *addressBook = @[];
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] initWithAddressBookData:addressBook];

    NSArray *array = [syncer groupContactsForMerkleTreeWithHeight:4];
    // should be 2 ** (4 - 1) = 8 buckets
    XCTAssertEqual([array count], 8);
    XCTAssertEqualObjects([array objectAtIndex:0], @[]);
    XCTAssertEqualObjects([array objectAtIndex:1], @[]);
    XCTAssertEqualObjects([array objectAtIndex:2], @[]);
    XCTAssertEqualObjects([array objectAtIndex:3], @[]);
    XCTAssertEqualObjects([array objectAtIndex:4], @[]);
    XCTAssertEqualObjects([array objectAtIndex:5], @[]);
    XCTAssertEqualObjects([array objectAtIndex:6], @[]);
    XCTAssertEqualObjects([array objectAtIndex:7], @[]);
}

@end
