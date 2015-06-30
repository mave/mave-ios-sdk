//
//  MAVEABSyncManager.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEMerkleTree.h"

typedef NS_ENUM(NSInteger, MAVEContactSyncType) {
    MAVEContactSyncTypeNone,
    MAVEContactSyncTypeInitial,
    MAVEContactSyncTypeUpdate,
};

@interface MAVEABSyncManager : NSObject

@property (nonatomic, assign) BOOL fetchSuggestionsInitiated;

// These methods do the full process of syncing contacts, the first will pull contacts
// from the ios contacts api and the second lets you pass in the contacts to avoid pulling
// them twice when we're already working with them.
//
// Both methods will check the remote configuration flags for whether to sync contacts and
// whether to return suggested and do the right thing based on that configuration.
// The second method asks the server to return suggested friends
- (void)atLaunchSyncContactsAndPopulateSuggestedByPermissions;
- (void)syncContactsAndPopulateSuggestedInBackground:(NSArray *)contacts;

- (NSArray *)doSyncContacts:(NSArray *)contacts returnSuggested:(BOOL)returnSuggested;

// Synchronous methods to send data to server and process results
- (MAVEMerkleTree *)buildLocalContactsMerkleTreeFromContacts:(NSArray *)contacts;
- (MAVEContactSyncType)decideNeededSyncTypeCompareRemoteTreeRootToTree:(MAVEMerkleTree *)merkleTree;
// Helper to send the changeset, telling the server to return suggested if specified
- (NSArray *)sendContactsChangeset:(NSArray *)changeset
                        merkleTree:(MAVEMerkleTree *)merkleTree
                 isFullInitialSync:(BOOL)isFullInitialSync
         returnSuggestedHRIDTuples:(BOOL)returnSuggested;
// Helper to get suggested invites explicitly (as opposed to having them returned by the
// send changeset request) and map the returned hashed record IDs to MAVEABPerson objects
- (NSArray *)getSuggestedInvitesExplicitly;

- (NSArray *)changesetComparingFullRemoteTreeToTree:(MAVEMerkleTree *)merkleTree;


// OLD METHOD - now we should send the merkle tree & changesets, even if user
// has never synced address book before
// Helper to serialize the address book and gzip compress
// addressBook is an array of MAVEABPerson records
- (NSData *)serializeAndCompressAddressBook:(NSArray *)addressBook;

@end
