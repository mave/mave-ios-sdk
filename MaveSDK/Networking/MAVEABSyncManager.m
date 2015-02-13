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
static dispatch_once_t syncContactsOnceToken;

- (void)syncContactsInBackground:(NSArray *)contacts {

    // tmp, log the changeset of all contacts
//    MAVEMerkleTree *tmpMerkleTree = [self buildLocalContactsMerkleTreeFromContacts:contacts];
//    NSArray *changeset = [tmpMerkleTree changesetForEmptyTreeToMatchSelf];
//    MAVEDebugLog(@"Changeset: %@", changeset);

    dispatch_once(&syncContactsOnceToken, ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            MAVEDebugLog(@"Running contacts sync, found %lu contacts", [contacts count]);
            MAVEMerkleTree *localMerkleTree =
                [self buildLocalContactsMerkleTreeFromContacts:contacts];
            [self doSyncContacts:localMerkleTree];
        });
    });
}

- (MAVEMerkleTree *)buildLocalContactsMerkleTreeFromContacts:(NSArray *)contacts {
    MAVEMerkleTree *merkleTree = [[MAVEMerkleTree alloc]initWithHeight:MAVEABSyncMerkleTreeHeight
                                                             arrayData:contacts
                                                          dataKeyRange:MAVEMakeRange64(0, UINT64_MAX)
                                                     hashValueNumBytes:4];
    return merkleTree;
}

// This method is blocking (uses semaphores to wait for responses because it may need
// to do several steps in serial. Make sure to run in a background thread
- (void)doSyncContacts:(MAVEMerkleTree *)localContactsMerkleTree {
    @try {
        NSArray *changeset;
        switch ([self decideNeededSyncTypeCompareRemoteTreeRootToTree:localContactsMerkleTree]) {
            // Here the remote tree is in sync with current state so exit
            case MAVEContactSyncTypeNone: {
                return;
            }

            // Here the remote tree is different than current tree so we need to send
            // and update
            case MAVEContactSyncTypeUpdate: {
                changeset = [self changesetComparingFullRemoteTreeToTree:localContactsMerkleTree];

                break;
            }

            // Here the remote tree did not exist yet, so it's an initial sync
            case MAVEContactSyncTypeInitial: {
                changeset = [localContactsMerkleTree changesetForEmptyTreeToMatchSelf];
                break;
            }
        }

        MAVEDebugLog(@"CONTACT SYNC sending changeset: %@", changeset);
        [[MaveSDK sharedInstance].APIInterface sendContactsChangeset:changeset completionBlock:nil];
        [[MaveSDK sharedInstance].APIInterface sendContactsMerkleTree:localContactsMerkleTree];

    } @catch (NSException *exception) {
        MAVEErrorLog(@"Caught exception %@ doing contacts sync", exception);
    }
}


- (MAVEContactSyncType)decideNeededSyncTypeCompareRemoteTreeRootToTree:(MAVEMerkleTree *)merkleTree {
    // Fetch the merkle tree root from the server
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block BOOL isInitialSync = NO;
    __block NSString *remoteHashString;
    [[MaveSDK sharedInstance].APIInterface getRemoteContactsMerkleTreeRootWithCompletionBlock:^(NSError *error, NSDictionary *responseData) {
        if (error && [error.domain isEqualToString:MAVE_HTTP_ERROR_DOMAIN] && error.code == 404) {
            // 404 means this is the initial sync for this app device id
            isInitialSync = YES;
        } else {
            remoteHashString = [responseData objectForKey:@"value"];
            if (remoteHashString == (id)[NSNull null]) {
                remoteHashString = nil;
            }
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 30*NSEC_PER_SEC));
    if (isInitialSync) {
        return MAVEContactSyncTypeInitial;
    }

    // server response was invalid or timed out
    if ([remoteHashString length] == 0) {
        MAVEDebugLog(@"Skipping contacts sync because first request to server failed");
        return MAVEContactSyncTypeNone;
    }

    NSString *localHashString = [MAVEMerkleTreeHashUtils hexStringFromData:[merkleTree.root hashValue]];
    if ([remoteHashString isEqualToString: localHashString]) {
        MAVEDebugLog(@"Skipping contacts sync because merkle tree roots matched");
        return MAVEContactSyncTypeNone;
    } else {
        return MAVEContactSyncTypeUpdate;
    }
}


- (NSArray *)changesetComparingFullRemoteTreeToTree:(MAVEMerkleTree *)merkleTree {
    // Fetch the merkle tree dictionary from the server
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSInteger semaWaitCode;
    __block BOOL ok = YES;
    __block NSDictionary *remoteTreeDict;
    [[MaveSDK sharedInstance].APIInterface getRemoteContactsFullMerkleTreeWithCompletionBlock:^(NSError *error, NSDictionary *responseData) {
        if (error) {
            ok = NO;
        }
        remoteTreeDict = responseData;
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
    MAVEMerkleTree *remoteTree = [[MAVEMerkleTree alloc] initWithJSONObject:remoteTreeDict];
    NSArray *changeset = [merkleTree changesetForOtherTreeToMatchSelf:remoteTree];
    if ([changeset count] == 0) {
        MAVEDebugLog(@"Contacts already in sync with remote");
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