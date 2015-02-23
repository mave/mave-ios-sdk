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
#import "MAVEABUtils.h"
#import "MAVEABSyncManager.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVEABPerson.h"
#import "MAVEConstants.h"
#import "MAVECompressionUtils.h"
#import "MaveSDK.h"
#import "MAVEAPIInterface.h"
#import "MAVEMerkleTree.h"
#import "MAVEMerkleTreeInnerNode.h"
#import "MAVEMerkleTreeLeafNode.h"
#import "MAVEMerkleTreeHashUtils.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEABSyncManager(Testing)
+ (NSInteger)valueOfSyncContactsOnceToken;
+ (void)resetSyncContactsOnceTokenForTesting;
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

- (void)testAtLaunchSyncContactsAndPopulateSuggestedByPermissionsWhenHavePermission {
    [MAVEABSyncManager resetSyncContactsOnceTokenForTesting];
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id syncerMock = OCMPartialMock(syncer);
    id abUtilsMock = OCMClassMock([MAVEABUtils class]);
    id promptHandlerMock = OCMClassMock([MAVEABPermissionPromptHandler class]);

    // set permissions yes and return fake contacts
    OCMExpect([abUtilsMock addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusAllowed);
    NSArray *fakeContacts = @[];
    OCMExpect([promptHandlerMock loadAddressBookSynchronouslyIfPermissionGranted]).andReturn(fakeContacts);

    OCMExpect([syncerMock syncContactsAndPopulateSuggestedInBackground:fakeContacts]);

    [syncer atLaunchSyncContactsAndPopulateSuggestedByPermissions];

    OCMVerifyAllWithDelay(syncerMock, 0.25);
    OCMVerifyAllWithDelay(abUtilsMock, 0.25);
    OCMVerifyAllWithDelay(promptHandlerMock, 0.25);
}

- (void)testAtLaunchSyncContactsAndPopulateSuggestedByPermissionsWhenNoPermission {
    [MaveSDK resetSharedInstanceForTesting];
    [MAVEABSyncManager resetSyncContactsOnceTokenForTesting];

    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id syncerMock = OCMPartialMock(syncer);
    id abUtilsMock = OCMClassMock([MAVEABUtils class]);
    id promiseMock = OCMPartialMock([MaveSDK sharedInstance].suggestedInvitesBuilder.promise);

    // Return no permissions
    OCMExpect([abUtilsMock addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusDenied);

    [[syncerMock reject] syncContactsAndPopulateSuggestedInBackground:[OCMArg any]];
    OCMExpect([promiseMock rejectPromise]);

    [syncer atLaunchSyncContactsAndPopulateSuggestedByPermissions];

    OCMVerifyAll(syncerMock);
    OCMVerifyAll(abUtilsMock);
    OCMVerifyAll(promiseMock);
}

- (void)testAtLaunchSyncContactsAndPopulateSuggestedByPermissionsWhenPermissionUnprompted {
    [MaveSDK resetSharedInstanceForTesting];
    [MAVEABSyncManager resetSyncContactsOnceTokenForTesting];

    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id syncerMock = OCMPartialMock(syncer);
    id abUtilsMock = OCMClassMock([MAVEABUtils class]);
    id promiseMock = OCMPartialMock([MaveSDK sharedInstance].suggestedInvitesBuilder.promise);

    // Return permissions not yet prompted
    OCMExpect([abUtilsMock addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusUnprompted);

    [[syncerMock reject] syncContactsAndPopulateSuggestedInBackground:[OCMArg any]];
    [[promiseMock reject] rejectPromise];

    [syncer atLaunchSyncContactsAndPopulateSuggestedByPermissions];

    OCMVerifyAll(syncerMock);
    OCMVerifyAll(abUtilsMock);
    OCMVerifyAll(promiseMock);
}



- (void)testSyncContactsAndPopulateInBackgroundWhenSyncYesUseSuggestedYes {
    [MaveSDK resetSharedInstanceForTesting];
    [MAVEABSyncManager resetSyncContactsOnceTokenForTesting];

    // use a remote configuration that enables contacts sync
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    MAVERemoteConfiguration *config = [[MAVERemoteConfiguration alloc] init];
    config.contactsSync = [[MAVERemoteConfigurationContactsSync alloc] init];
    config.contactsSync.enabled = YES;
    OCMExpect([maveMock remoteConfiguration]).andReturn(config);

    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id syncerMock = OCMPartialMock(syncer);

    NSArray *fakeAllContacts = @[@"asdf", @"sdfg"];
    NSArray *suggestedContacts = @[@"foo", @"bar"];
    OCMExpect([syncerMock doSyncContacts:fakeAllContacts returnSuggested:YES]).andReturn(suggestedContacts);

    id promiseMock = OCMPartialMock([MaveSDK sharedInstance].suggestedInvitesBuilder.promise);
    NSValue *expectedFulfillVal = (NSValue *)@{@"closest_contacts": suggestedContacts};
    OCMExpect([promiseMock fulfillPromise:expectedFulfillVal]);

    [syncer syncContactsAndPopulateSuggestedInBackground:fakeAllContacts];

    OCMVerifyAllWithDelay(maveMock, 0.25);
    OCMVerifyAllWithDelay(maveMock, 0.25);
    OCMVerifyAllWithDelay(maveMock, 0.25);
}

- (void)testSyncContactsAndPopulateInBackgroundWhenSyncNoUseSuggestedYes {
    [MaveSDK resetSharedInstanceForTesting];
    [MAVEABSyncManager resetSyncContactsOnceTokenForTesting];

    // use a remote configuration that disables contact sync
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    MAVERemoteConfiguration *config = [[MAVERemoteConfiguration alloc] init];
    config.contactsSync = [[MAVERemoteConfigurationContactsSync alloc] init];
    config.contactsSync.enabled = NO;
    OCMExpect([maveMock remoteConfiguration]).andReturn(config);

    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id syncerMock = OCMPartialMock(syncer);
    [[syncerMock reject] buildLocalContactsMerkleTreeFromContacts:[OCMArg any]];

    [syncer syncContactsAndPopulateSuggestedInBackground:@[]];

    OCMVerifyAllWithDelay(syncerMock, 0.1);
    OCMVerifyAllWithDelay(maveMock, 0.1);
}

- (void)testSyncContactsAndPopulateInBackgroundWhenSyncYesUseSuggestedNO {
    XCTAssertFalse(YES);
}

- (void)testSyncContactsAndPopulateInBackgroundWhenSyncNoUseSuggestedNo {
    XCTAssertFalse(YES);
}


- (void)testBuildLocalContactsMerkleTree {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.firstName = @"2"; p1.lastName = @"3";
    NSArray *contacts = @[p1];
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];

    MAVEMerkleTree *tree = [syncer buildLocalContactsMerkleTreeFromContacts:contacts];

    // Should build a tree with height 11, 4 bytes used in hash values, and data key range
    // that matches the hashed record ID size of MAVEABPerson record id's
    XCTAssertEqual([tree.root treeHeight], 11);
    XCTAssertEqual([[tree.root hashValue] length], 4);
    // Traverse to leftmost child and check that range is what we expect
    MAVEMerkleTreeInnerNode *node = tree.root;
    for (int i = 0; i < 9; ++i) {
        node = node.leftChild;
    }
    MAVEMerkleTreeLeafNode *leaf = node.leftChild;
    XCTAssertEqual(leaf.dataKeyRange.location, 0);
    // since we're 10 layers below root of the tree, the range length should be the following:
    uint64_t expectedKeyLength = exp2(64 - (11 - 1));
    XCTAssertEqual(leaf.dataKeyRange.length, expectedKeyLength);
    // Since there's 1 item in our tree, diffing against empty should give a changeset of length 1
    NSArray *changeset = [tree changesetForEmptyTreeToMatchSelf];
    XCTAssertEqual([changeset count], 1);
}

///
/// Thorough, almost integration level tests of the method to sync contacts and return the
/// suggested invites
///
- (void)testDoSyncContactsReturningSuggestedShouldSkip {
    // set up to return instructions not to sync
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.hashedRecordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.hashedRecordID = 1;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.hashedRecordID = 2;
    NSArray *fakeContacts = @[p0, p1, p2];
    id mock = OCMPartialMock(syncer);
    id merkleTreeMock = OCMClassMock([MAVEMerkleTree class]);
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);

    // mock the method that returns the merkle tree
    OCMExpect([mock buildLocalContactsMerkleTreeFromContacts:fakeContacts]).andReturn(merkleTreeMock);

    // mock the method that determines if we sync or not
    OCMExpect([mock decideNeededSyncTypeCompareRemoteTreeRootToTree:merkleTreeMock])
        .andReturn(MAVEContactSyncTypeNone);

    // assert that we don't sync contacts
    [[mock reject] changesetComparingFullRemoteTreeToTree:[OCMArg any]];
    [[apiInterfaceMock reject] sendContactsChangeset:[OCMArg any] returnClosestContacts:NO completionBlock:[OCMArg any]];
    [[apiInterfaceMock reject] sendContactsMerkleTree:[OCMArg any]];
    // we should fetch suggested separately since we're not syncing
    NSArray *fakeSuggestedHashedRecordIDs = @[@1, @2];
    OCMExpect([apiInterfaceMock getClosestContactsHashedRecordIDs:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^contactsBlock)(NSArray *contacts) = obj;
        contactsBlock(fakeSuggestedHashedRecordIDs);
        return YES;
    }]]);

    NSArray *closestContacts = [syncer doSyncContacts:fakeContacts returnSuggested:YES];
    NSArray *expectedSuggested = @[p1, p2];
    XCTAssertEqualObjects(closestContacts, expectedSuggested);
    OCMVerifyAll(mock);
    OCMVerifyAll(merkleTreeMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testDoSyncContactsReturningSuggestedInitialSync {
    // If server indicates that it's the initial sync, don't even fetch the full merkle tree
    // to compare it, just diff against an empty tree to return everything
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.hashedRecordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.hashedRecordID = 1;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.hashedRecordID = 2;
    NSArray *fakeContacts = @[p0, p1, p2];
    id mock = OCMPartialMock(syncer);
    id merkleTreeMock = OCMClassMock([MAVEMerkleTree class]);

    // mock the method that returns the merkle tree
    OCMExpect([mock buildLocalContactsMerkleTreeFromContacts:fakeContacts]).andReturn(merkleTreeMock);

    // Mock to force the initial sync state
    OCMExpect([mock decideNeededSyncTypeCompareRemoteTreeRootToTree:merkleTreeMock])
        .andReturn(MAVEContactSyncTypeInitial);

    // Make sure we don't compare to the full remote tree, instead we should compare to an empty
    // tree since we know it's the first sync
    [[mock reject] changesetComparingFullRemoteTreeToTree:[OCMArg any]];
    NSArray *fakeChangeset = @[@"foo", @"bar"];
    OCMExpect([merkleTreeMock changesetForEmptyTreeToMatchSelf]).andReturn(fakeChangeset);
    // And then send resulting changeset to the server
    NSArray *fakeClosestContacts = @[@"blah", @"blah"];
    OCMExpect([mock sendContactsChangeset:fakeChangeset merkleTree:merkleTreeMock returnSuggested:YES]).andReturn(fakeClosestContacts);

    NSArray *closestContacts = [syncer doSyncContacts:fakeContacts returnSuggested:YES];

    XCTAssertEqualObjects(closestContacts, fakeClosestContacts);
    OCMVerifyAll(mock);
    OCMVerifyAll(merkleTreeMock);
}

// When an update needs to be done, compare full tree to get the diff and then send the difference
- (void)testDoSyncContactsReturningSuggestedCompareFullTreeWithRemote {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init]; p0.hashedRecordID = 0;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.hashedRecordID = 1;
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.hashedRecordID = 2;
    NSArray *fakeContacts = @[p0, p1, p2];
    id mock = OCMPartialMock(syncer);
    id merkleTreeMock = OCMClassMock([MAVEMerkleTree class]);

    // mock the method that returns the merkle tree
    OCMExpect([mock buildLocalContactsMerkleTreeFromContacts:fakeContacts]).andReturn(merkleTreeMock);

    // mock to force the update diff state
    OCMExpect([mock decideNeededSyncTypeCompareRemoteTreeRootToTree:merkleTreeMock]).andReturn(MAVEContactSyncTypeUpdate);

    NSArray *fakeChangeset = @[@"foo"];
    OCMExpect([mock changesetComparingFullRemoteTreeToTree:merkleTreeMock]).andReturn(fakeChangeset);
    NSArray *fakeClosestContacts = @[@"blah", @"blah"];
    OCMExpect([mock sendContactsChangeset:fakeChangeset merkleTree:merkleTreeMock returnSuggested:YES]).andReturn(fakeClosestContacts);

    NSArray *closestContacts = [syncer doSyncContacts:fakeContacts returnSuggested:YES];

    XCTAssertEqualObjects(closestContacts, fakeClosestContacts);
    OCMVerifyAll(mock);
    OCMVerifyAll(merkleTreeMock);
}

- (void)testDecideNeededSyncWhenRemoteMerkleTreeExists {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    NSDictionary *responseDict = @{@"value": @"000001"};
    OCMExpect([apiInterfaceMock getRemoteContactsMerkleTreeRootWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSError *error, NSDictionary *responseData) = obj;
        completionBlock(nil, responseDict);
        return YES;
    }]]);

    // When data is the same we're done
    MAVEMerkleTree *tree1 = [[MAVEMerkleTree alloc] initWithJSONObject:@{@"k": @"000001"}];
    MAVEContactSyncType syncType1 = [syncer decideNeededSyncTypeCompareRemoteTreeRootToTree:tree1];
    XCTAssertEqual(syncType1, MAVEContactSyncTypeNone);
    [apiInterfaceMock stopMocking];

    // When data is different we're not done
    apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock getRemoteContactsMerkleTreeRootWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSError *error, NSDictionary *responseData) = obj;
        completionBlock(nil, responseDict);
        return YES;
    }]]);
    MAVEMerkleTree *tree2 = [[MAVEMerkleTree alloc] initWithJSONObject:@{@"k": @"aaaaffff"}];
    MAVEContactSyncType syncType2 = [syncer decideNeededSyncTypeCompareRemoteTreeRootToTree:tree2];
    XCTAssertEqual(syncType2, MAVEContactSyncTypeUpdate);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testDecideNeededSyncWhenRemoteMerkleTreeNotExists {
    // The query for the root returns 200 with a json value=null when the tree doesn't exist
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock getRemoteContactsMerkleTreeRootWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSError *error, NSDictionary *responseData) = obj;
        NSDictionary *response = @{@"value": [NSNull null]};
        completionBlock(nil, response);
        return YES;
    }]]);

    // This is treated as being in initial sync state
    MAVEMerkleTree *tree1 = [[MAVEMerkleTree alloc] initWithJSONObject:@{@"k": @"000001"}];
    MAVEContactSyncType syncType1 = [syncer decideNeededSyncTypeCompareRemoteTreeRootToTree:tree1];
    XCTAssertEqual(syncType1, MAVEContactSyncTypeInitial);
    [apiInterfaceMock stopMocking];
}

- (void)testDecideNeededSyncWhenRemoteMerkleTreeRequestError {
    // return a non-404 error meaning the request failed somehow
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock getRemoteContactsMerkleTreeRootWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSError *error, NSDictionary *responseData) = obj;
        NSError *returnError = [[NSError alloc] initWithDomain:MAVE_HTTP_ERROR_DOMAIN code:503 userInfo:@{}];
        completionBlock(returnError, nil);
        return YES;
    }]]);

    // Should not sync in this case, something's wrong on the server
    MAVEMerkleTree *tree1 = [[MAVEMerkleTree alloc] initWithJSONObject:@{@"k": @"000001"}];
    MAVEContactSyncType syncType1 = [syncer decideNeededSyncTypeCompareRemoteTreeRootToTree:tree1];
    XCTAssertEqual(syncType1, MAVEContactSyncTypeNone);
    [apiInterfaceMock stopMocking];
}

- (void)testChangesetComparingFullTrees {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    NSDictionary *responseDict = @{@"k": @"000001"};
    OCMExpect([apiInterfaceMock getRemoteContactsFullMerkleTreeWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSError *error, NSDictionary *responseData) = obj;
        completionBlock(nil, responseDict);
        return YES;
    }]]);

    id treeMock = OCMClassMock([MAVEMerkleTree class]);
    NSArray *fakeChangeset = @[@"foo"];
    OCMExpect([treeMock changesetForOtherTreeToMatchSelf:[OCMArg checkWithBlock:^BOOL(id obj) {
        MAVEMerkleTree *remoteTree = obj;
        return [[MAVEMerkleTreeHashUtils hexStringFromData:[remoteTree.root hashValue]] isEqualToString:@"000001"];
    }]]).andReturn(fakeChangeset);

    NSArray *returnedChangeset = [syncer changesetComparingFullRemoteTreeToTree:treeMock];
    XCTAssertEqualObjects(returnedChangeset, fakeChangeset);

    OCMVerifyAll(treeMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testSendContactsChangesetAndMerkleTreeReturnSuggested {
    MAVEABSyncManager *syncer = [[MAVEABSyncManager alloc] init];
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);

    NSArray *fakeChangeset = @[@"fake"];
    id fakeMerkleTree = @"fake tree";
    NSArray *suggestedHashedRecordIDs = @[@"1", @"2"];
    OCMExpect([apiInterfaceMock sendContactsChangeset:fakeChangeset
                                   returnClosestContacts:YES
                                         completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSArray *suggestions) = obj;
        completionBlock(suggestedHashedRecordIDs);
        return YES;
    }]]);
    OCMExpect([apiInterfaceMock sendContactsMerkleTree:fakeMerkleTree]);

    // run the code under test
    NSArray *returnedSuggested = [syncer sendContactsChangeset:fakeChangeset merkleTree:fakeMerkleTree returnSuggested:YES];

    XCTAssertEqualObjects(returnedSuggested, suggestedHashedRecordIDs);
    OCMVerifyAll(apiInterfaceMock);
}


- (void)testSerializeAndCompress {
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.firstName = @"Danny"; p1.lastName = @"Cosson";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.recordID = 2; p2.firstName = @"Foo"; p2.lastName = @"Bar";
    NSArray *addressBook = @[p2, p1];
    MAVEABSyncManager *manager = [[MAVEABSyncManager alloc] init];
    NSArray *expectedAB = @[p2, p1];  // won't be sorted yet on init
    XCTAssertEqualObjects(addressBook, expectedAB);
    NSData *output = [manager serializeAndCompressAddressBook:addressBook];
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
