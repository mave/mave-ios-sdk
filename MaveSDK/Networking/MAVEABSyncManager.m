//
//  MAVEABSyncManager.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <zlib.h>
#import "MAVEABSyncManager.h"
#import "MAVEABUtils.h"
#import "MAVEABPermissionPromptHandler.h"
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
+ (NSInteger)valueOfSyncContactsOnceToken {
    return syncContactsOnceToken;
}
+ (void)resetSyncContactsOnceTokenForTesting {
    syncContactsOnceToken = 0;
}

- (void)syncContactsInBackgroundIfAlreadyHavePermission {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @try {
            NSArray *contacts = [MAVEABPermissionPromptHandler loadAddressBookSynchronouslyIfPermissionGranted];
            if (contacts) {
                [self syncContactsAndPopulateSuggestedInBackground:contacts];
            }
        } @catch (NSException *exception) {
            MAVEErrorLog(@"Exception doing sync contacts if background if already have permission %@", exception);
        }
    });
}

// This method is called at app launch, if we already have permission to access contacts we run the contacts sync
// which will
- (void)atLaunchSyncContactsAndPopulateSuggestedByPermissions {
    NSString *contactsPermission = [MAVEABUtils addressBookPermissionStatus];

    if ([contactsPermission isEqualToString:MAVEABPermissionStatusAllowed]) {
        NSArray *contacts = [MAVEABPermissionPromptHandler loadAddressBookSynchronouslyIfPermissionGranted];
        [self syncContactsAndPopulateSuggestedInBackground:contacts];

    } else if ([contactsPermission isEqualToString:MAVEABPermissionStatusDenied]) {
        // If we don't have address book permissions we won't show the contacts invite page anyway so we
        // don't need suggested invites, just set it now as empty.

    } else {
        // User has not been prompted for contacts permission yet.
        // Do nothing, if user does grant permission later we'll sync contacts and fetch suggested then

    }
}

- (void)syncContactsAndPopulateSuggestedInBackground:(NSArray *)contacts {
    dispatch_once(&syncContactsOnceToken, ^{
        // tmp, log the changeset of all contacts
        //    MAVEMerkleTree *tmpMerkleTree = [self buildLocalContactsMerkleTreeFromContacts:contacts];
        //    NSArray *changeset = [tmpMerkleTree changesetForEmptyTreeToMatchSelf];
        //    MAVEDebugLog(@"Changeset: %@", changeset);

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Only sync contacts if the current configuration allows it
            BOOL syncEnabled = [MaveSDK sharedInstance].remoteConfiguration.contactsSync.enabled;

            if (syncEnabled) {
                MAVEInfoLog(@"Running contacts sync, found %lu contacts", [contacts count]);
                [self doSyncContacts:contacts returnSuggested:YES];
            }
        });
    });
}

- (MAVEMerkleTree *)buildLocalContactsMerkleTreeFromContacts:(NSArray *)contacts {
    MAVEMerkleTree *merkleTree = nil;
    @try {
        merkleTree = [[MAVEMerkleTree alloc]initWithHeight:MAVEABSyncMerkleTreeHeight
                                                 arrayData:contacts
                                              dataKeyRange:MAVEMakeRange64(0, UINT64_MAX)
                                         hashValueNumBytes:4];
    } @catch (NSException *exception) {
        MAVEErrorLog(@"Building local merkle tree raised exception %@, won't continue with sync", exception);
    }
    @finally {
        return merkleTree;
    }
}

// This method is blocking (uses semaphores to wait for responses because it may need
// to do several steps in serial. Make sure to run in a background thread
- (NSArray *)doSyncContacts:(NSArray *)contacts returnSuggested:(BOOL)returnSuggested {
    @try {
        MAVEMerkleTree *localContactsMerkleTree = [self buildLocalContactsMerkleTreeFromContacts:contacts];

        NSArray *changeset;
        switch ([self decideNeededSyncTypeCompareRemoteTreeRootToTree:localContactsMerkleTree]) {
            // Here the remote tree is in sync with current state so no need to sync
            // We just query for closest contacts instead and return that.
            case MAVEContactSyncTypeNone: {

                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                __block NSArray *closestHashedRecordIDs = @[];
                [[MaveSDK sharedInstance].APIInterface getClosestContactsHashedRecordIDs:^(NSArray *_closestHashedRecordIDs) {
                    if ([_closestHashedRecordIDs count] > 0) {
                        closestHashedRecordIDs = _closestHashedRecordIDs;
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                return [MAVEABUtils listofABPersonsFromListOfHashedRecordIDs:closestHashedRecordIDs
                                                              andAllContacts:contacts];
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

        return [self sendContactsChangeset:changeset
                                merkleTree:localContactsMerkleTree
                           returnSuggested:returnSuggested];

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
        if (error) {
            // treat error as no response
            remoteHashString = nil;
        } else {
            // if the tree was not found, server will have returned {"value": null} json, check for that case
            remoteHashString = [responseData objectForKey:@"value"];
            if (remoteHashString == (id)[NSNull null]) {
                isInitialSync = YES;
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

- (NSArray *)sendContactsChangeset:(NSArray *)changeset
                        merkleTree:(MAVEMerkleTree *)merkleTree
                   returnSuggested:(BOOL)returnSuggested {
    MAVEDebugLog(@"CONTACT SYNC sending changeset: %@", changeset);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSArray *returnVal;
    [[MaveSDK sharedInstance].APIInterface sendContactsChangeset:changeset returnClosestContacts:returnSuggested completionBlock:^(NSArray *closestContacts) {
        returnVal = closestContacts;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [[MaveSDK sharedInstance].APIInterface sendContactsMerkleTree:merkleTree];
    return returnVal;
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