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
#import "MAVEHashingUtils.h"

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

- (void)testDoSyncContactsShouldSkip {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id mock = OCMPartialMock(syncer);
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([mock shouldSkipSyncCompareRemoteTreeRootToTree:[OCMArg any]]).andReturn(YES);
    [[mock reject] changesetComparingFullRemoteTreeToTree:[OCMArg any]];
    [[apiInterfaceMock reject] sendContactsMerkleTree:[OCMArg any] changeset:[OCMArg any]];

    [syncer doSyncContactsInCurrentThread:@[]];

    OCMVerifyAll(mock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testDoSyncContactsSkipBecauseChangesetEmpty {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id mock = OCMPartialMock(syncer);
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([mock shouldSkipSyncCompareRemoteTreeRootToTree:[OCMArg any]]).andReturn(NO);
    NSArray *fakeChangeset = @[];
    OCMExpect([mock changesetComparingFullRemoteTreeToTree:[OCMArg any]]).andReturn(fakeChangeset);
    [[apiInterfaceMock reject] sendContactsMerkleTree:[OCMArg any] changeset:fakeChangeset];

    [syncer doSyncContactsInCurrentThread:@[]];

    OCMVerifyAll(mock);
}

- (void)testDoSyncContactsNoSkip {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id mock = OCMPartialMock(syncer);
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([mock shouldSkipSyncCompareRemoteTreeRootToTree:[OCMArg any]]).andReturn(NO);
    NSArray *fakeChangeset = @[@"foo"];
    OCMExpect([mock changesetComparingFullRemoteTreeToTree:[OCMArg any]]).andReturn(fakeChangeset);
    OCMExpect([apiInterfaceMock sendContactsMerkleTree:[OCMArg any] changeset:fakeChangeset]);

    [syncer doSyncContactsInCurrentThread:@[]];

    OCMVerifyAll(mock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testShouldSkipSyncCompareRoots {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    NSDictionary *responseDict = @{@"data": @"000001"};
    OCMExpect([apiInterfaceMock getRemoteContactsMerkleTreeRootWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSError *error, NSDictionary *responseData) = obj;
        completionBlock(nil, responseDict);
        return YES;
    }]]);

    // When data is the same we're done
    MAVEMerkleTree *tree1 = [[MAVEMerkleTree alloc] initWithJSONObject:@{@"k": @"000001"}];
    BOOL done = [syncer shouldSkipSyncCompareRemoteTreeRootToTree:tree1];
    XCTAssertTrue(done);
    [apiInterfaceMock stopMocking];

    // When data is different we're not done
    apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock getRemoteContactsMerkleTreeRootWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSError *error, NSDictionary *responseData) = obj;
        completionBlock(nil, responseDict);
        return YES;
    }]]);
    MAVEMerkleTree *tree2 = [[MAVEMerkleTree alloc] initWithJSONObject:@{@"k": @"aaaaffff"}];
    BOOL done2 = [syncer shouldSkipSyncCompareRemoteTreeRootToTree:tree2];
    XCTAssertFalse(done2);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testChangesetComparingFullTrees {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    NSDictionary *responseDict = @{@"data": @{@"k": @"000001"}};
    OCMExpect([apiInterfaceMock getRemoteContactsFullMerkleTreeWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSError *error, NSDictionary *responseData) = obj;
        completionBlock(nil, responseDict);
        return YES;
    }]]);

    id treeMock = OCMClassMock([MAVEMerkleTree class]);
    NSArray *fakeChangeset = @[@"foo"];
    OCMExpect([treeMock changesetForOtherTreeToMatchSelf:[OCMArg checkWithBlock:^BOOL(id obj) {
        MAVEMerkleTree *remoteTree = obj;
        return [[MAVEHashingUtils hexStringFromData:[remoteTree.root hashValue]] isEqualToString:@"000001"];
    }]]).andReturn(fakeChangeset);

    NSArray *returnedChangeset = [syncer changesetComparingFullRemoteTreeToTree:treeMock];
    XCTAssertEqualObjects(returnedChangeset, fakeChangeset);

    OCMVerifyAll(treeMock);
    OCMVerifyAll(apiInterfaceMock);
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

@end
