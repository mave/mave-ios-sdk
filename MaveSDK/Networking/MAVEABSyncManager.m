//
//  MAVEABSyncManager.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <zlib.h>
#import "MAVEABSyncManager.h"
#import "MAVEABPerson.h"
#import "MAVEConstants.h"
#import "MAVECompressionUtils.h"
#import "MAVEAPIInterface.h"
#import "MAVEMerkleTreeHashUtils.h"
#import "MaveSDK.h"

NSUInteger const MAVEABSyncMerkleTreeHeight = 11;

@implementation MAVEABSyncManager

// Use dispatch_once to make sure we only call syncContacts once per session. This
// way we don't need any logic to decide where to call it, we can just hook into
// wherever we access the contacts and call it there.
static dispatch_once_t syncOnceToken;

- (void)syncContactsInBackground:(NSArray *)contacts {

    // tmp, log the changeset of all contacts
    NSRange merkleTreeRange = NSMakeRange(0, MAVEABPersonHashedRecordIDNumBytes);
    MAVEMerkleTree *merkleTree = [[MAVEMerkleTree alloc]initWithHeight:MAVEABSyncMerkleTreeHeight
                                                             arrayData:contacts
                                                          dataKeyRange:merkleTreeRange
                                                     hashValueNumBytes:4];
    MAVEMerkleTree *emptyMT = [[MAVEMerkleTree alloc] initWithHeight:1
                                                           arrayData:@[]
                                                        dataKeyRange:merkleTreeRange
                                                   hashValueNumBytes:4];

    NSArray *changeset = [merkleTree changesetForOtherTreeToMatchSelf:emptyMT];
    MAVEDebugLog(@"Changeset: %@", changeset);



    dispatch_once(&syncOnceToken, ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self doSyncContacts:contacts];
        });
    });
}

- (void)doSyncContacts:(NSArray *)contacts {
    @try {
        MAVEDebugLog(@"Running contacts sync, found %lu contacts", [contacts count]);
        NSRange dataKeyRange = NSMakeRange(0, exp2(48));
        MAVEMerkleTree *merkleTree = [[MAVEMerkleTree alloc]initWithHeight:MAVEABSyncMerkleTreeHeight
                                                                 arrayData:contacts
                                                              dataKeyRange:dataKeyRange hashValueNumBytes:4];

        BOOL done = [self shouldSkipSyncCompareRemoteTreeRootToTree:merkleTree];
        if (done) {
            return;
        }

        NSArray *changeset = [self changesetComparingFullRemoteTreeToTree:merkleTree];
        // If roots were different changeset should not be empty, but if something got
        // out of sync or timed out we'll get here
        if ([changeset count] == 0) {
            MAVEErrorLog(@"Contact sync changeset unexpectedly zero");
            return;
        }

        [[MaveSDK sharedInstance].APIInterface sendContactsMerkleTree:merkleTree
                                                            changeset:changeset];
    } @catch (NSException *exception) {
        MAVEErrorLog(@"Caught exception %@ doing contacts sync", exception);
    }
}


- (BOOL)shouldSkipSyncCompareRemoteTreeRootToTree:(MAVEMerkleTree *)merkleTree {
    // Fetch the merkle tree root from the server
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block NSString *remoteHashString;
    [[MaveSDK sharedInstance].APIInterface getRemoteContactsMerkleTreeRootWithCompletionBlock:^(NSError *error, NSDictionary *responseData) {
        remoteHashString = [responseData objectForKey:@"data"];
        if (remoteHashString == (id)[NSNull null]) {
            remoteHashString = nil;
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 30*NSEC_PER_SEC));
    // server response was invalid or timed out
    if ([remoteHashString length] == 0) {
        MAVEDebugLog(@"Skipping contacts sync because first request to server timed out");
        return YES;
    }

    NSString *localHashString = [MAVEMerkleTreeHashUtils hexStringFromData:[merkleTree.root hashValue]];
    BOOL output = ([remoteHashString isEqualToString: localHashString]);
    if (output) {
        MAVEDebugLog(@"Skipping contacts sync because tree roots matched");
    }
    return output;
}


- (NSArray *)changesetComparingFullRemoteTreeToTree:(MAVEMerkleTree *)merkleTree {
    // Fetch the merkle tree dictionary from the server
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSInteger semaWaitCode;
    __block BOOL ok = YES;
    __block NSDictionary *returnedData;
    [[MaveSDK sharedInstance].APIInterface getRemoteContactsFullMerkleTreeWithCompletionBlock:^(NSError *error, NSDictionary *responseData) {
        if (error) {
            ok = NO;
        }
        returnedData = responseData;
        dispatch_semaphore_signal(sema);
    }];
    semaWaitCode = dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 30*NSEC_PER_SEC));
    if (semaWaitCode != 0) {
        ok = NO;
    }
    if (!ok) {
        return nil;
    }

    // Build remote tree object & compare to our own tree
    NSDictionary *remoteTreeDict = [returnedData objectForKey:@"data"];
    MAVEMerkleTree *remoteTree = [[MAVEMerkleTree alloc] initWithJSONObject:remoteTreeDict];
    NSArray *changeset = [merkleTree changesetForOtherTreeToMatchSelf:remoteTree];
    if ([changeset count] == 0) {
        MAVEInfoLog(@"Contacts already in sync with remote");
    }
    return changeset;
}



- (NSData *)serializeAndCompressAddressBook:(NSArray *)addressBook {
    NSMutableArray *dictPeople = [[NSMutableArray alloc] initWithCapacity:[addressBook count]];
    MAVEABPerson *person; NSDictionary *dictPerson;

    NSArray *sortedAddressBook = [addressBook sortedArrayUsingSelector:@selector(compareRecordIDs:)];

    for (person in sortedAddressBook) {
        dictPerson = [person toJSONDictionary];
        if (dictPerson) {
            [dictPeople addObject:dictPerson];
        }
    }

    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictPeople
                                                   options:0
                                                     error:&err];
    if (err) {
        MAVEErrorLog(@"error serializing JSON for address book sync: %@", err);
        return nil;
    }
    return [MAVECompressionUtils gzipCompressData:data];
}


@end