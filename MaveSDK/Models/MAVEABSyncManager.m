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

@implementation MAVEABSyncManager

- (instancetype)initWithAddressBookData:(NSArray *)personsArray {
    if (self = [super init]) {
        self.addressBook = [personsArray sortedArrayUsingSelector:@selector(compareRecordIDs:)];
    }
    return self;
}

- (NSData *)serializeAndCompressAddressBook {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.addressBook
                                                   options:0
                                                     error:&err];
    if (err) {
        MAVEErrorLog(@"error serializing JSON for address book sync: %@", err);
        return nil;
    }
    return [MAVECompressionUtils gzipCompressData:data];
}

- (void)sendContactsToServer {

}



@end