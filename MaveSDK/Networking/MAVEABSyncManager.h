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

// These methods do the full process of syncing contacts, the first will pull contacts
// from the ios contacts api and the second lets you pass in the contacts to avoid pulling
// them twice when we're already working with them.
//
// Both methods will check the remote configuration flag and if syncing contacts is disabled
// they do not actually sync.
// The second method asks the server to return suggested friends 
- (void)syncContactsInBackgroundIfAlreadyHavePermission;
- (void)syncContactsInBackground:(NSArray *)contacts;


- (void)doSyncContacts:(MAVEMerkleTree *)localContactsMerkleTree;

- (MAVEMerkleTree *)buildLocalContactsMerkleTreeFromContacts:(NSArray *)contacts;
- (MAVEContactSyncType)decideNeededSyncTypeCompareRemoteTreeRootToTree:(MAVEMerkleTree *)merkleTree;

- (NSArray *)changesetComparingFullRemoteTreeToTree:(MAVEMerkleTree *)merkleTree;


// OLD METHOD - now we should send the merkle tree & changesets, even if user
// has never synced address book before
// Helper to serialize the address book and gzip compress
// addressBook is an array of MAVEABPerson records
- (NSData *)serializeAndCompressAddressBook:(NSArray *)addressBook;

@end
