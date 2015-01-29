//
//  MAVEABSyncManager.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEMerkleTree.h"

@interface MAVEABSyncManager : NSObject

// addressBook is an array of MAVEABPerson records
@property (nonatomic, strong) NSArray *addressBook;

// addressBook is an array of MAVEABPerson records
- (instancetype)initWithAddressBookData:(NSArray *)addressBook;

// pass it an array of MAVEABPerson objects, it will do the full process
//   of syncing the contacts to the server
- (void)syncContacts:(NSArray *)contacts;
- (void)doSyncContactsInCurrentThread:(NSArray *)contacts;
- (BOOL)shouldSkipSyncCompareRemoteTreeRootToTree:(MAVEMerkleTree *)merkleTree;
- (NSArray *)changesetComparingFullRemoteTreeToTree:(MAVEMerkleTree *)merkleTree;

// Helper to serialize the address book and gzip compress
- (NSData *)serializeAndCompressAddressBook;

@end
