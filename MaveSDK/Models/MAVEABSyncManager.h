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


@end
