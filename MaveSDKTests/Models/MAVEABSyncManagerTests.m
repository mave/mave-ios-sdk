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

@end
