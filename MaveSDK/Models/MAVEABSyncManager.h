//
//  MAVEABSyncManager.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVEABSyncManager : NSObject

// addressBook is an array of MAVEABPerson records
@property (nonatomic, strong) NSArray *addressBook;

// addressBook is an array of MAVEABPerson records
- (instancetype)initWithAddressBookData:(NSArray *)addressBook;

// Serialize the address book and send to server
- (void)sendContactsToServer;

// Helper to serialize the address book and gzip compress
- (NSData *)serializeAndCompressAddressBook;

// Put the address book into buckets that can be turned into a merkle tree.
// The data forms the leaves of the merkle tree, so the number of buckets of
//   needed is equal to the 2^(height of tree - 1) e.g. for a tree height
//   of 11 we'll create 1024 buckets.
// Grouping is done by bitshifting the recordID (which is a random int) such
//   that it becomes a random int between 0 and the number buckets and then
//   inserting the record into that group number.
//
// Returns an array with length equal to the number of buckets.
- (NSArray *)groupContactsForMerkleTreeWithHeight:(NSUInteger)height;

@end
