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

    NSArray *sortedAddressBook = [self.addressBook sortedArrayUsingSelector:@selector(compareRecordIDs:)];

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

- (void)sendContactsToServer {
    NSData *data = [self serializeAndCompressAddressBook];
    [[MaveSDK sharedInstance].APIInterface sendIdentifiedDataWithRoute:@"/address_book_upload" methodName:@"PUT" data:data];
}

- (NSArray *)groupContactsForMerkleTreeWithHeight:(NSUInteger)height {
    NSUInteger numberBuckets = pow(2, height - 1);

    // create a big array with the desired number of buckets
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:numberBuckets];
    for (NSUInteger i = 0; i < numberBuckets; ++i) {
        [array insertObject:[[NSMutableArray alloc] init] atIndex:i];
    }

    // loop through address book, appending the object to the correct array
    uint bucketIndex;
    NSMutableArray *tmpBucket;
    for (MAVEABPerson *person in self.addressBook) {
        bucketIndex = person.hashedRecordID >> (32 - (height-1));
        tmpBucket = [array objectAtIndex:bucketIndex];
        [tmpBucket addObject:person];
    }

    // Then loop through buckets to sort people and convert to JSON format
    NSInteger i; NSMutableArray *bucket; MAVEABPerson *person;
    for (bucket in array) {
        [bucket sortUsingSelector:@selector(compareHashedRecordIDs:)];
        for (i = 0; i < [bucket count]; ++i) {
            person = [bucket objectAtIndex:i];
            [bucket replaceObjectAtIndex:i
                              withObject:[person toJSONTupleArray]];
        }
    }

    NSArray *output = [array copy];
    return output;
}


@end