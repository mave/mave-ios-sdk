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
#import "MaveSDK.h"

@implementation MAVEABSyncManager

- (instancetype)initWithAddressBookData:(NSArray *)addressBook {
    if (self = [super init]) {
        self.addressBook = addressBook;
    }
    return self;
}

- (NSData *)serializeAndCompressAddressBook {
    NSMutableArray *dictPeople = [[NSMutableArray alloc] initWithCapacity:[self.addressBook count]];
    MAVEABPerson *person; NSDictionary *dictPerson;

    NSArray *sortedPeople = [self.addressBook sortedArrayUsingSelector:@selector(compareRecordIDs:)];
    for (person in sortedPeople) {
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

- (void)sendContactsToServer {
    NSData *data = [self serializeAndCompressAddressBook];
    [[MaveSDK sharedInstance].APIInterface sendIdentifiedDataWithRoute:@"/address_book_upload" methodName:@"PUT" data:data];
}



@end