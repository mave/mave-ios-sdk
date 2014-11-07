//
//  AddressBookDataCollection.m
//  MaveDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "MAVEABCollection.h"
#import "MAVEABCollection_Internal.h"
#import <AddressBook/AddressBook.h>
#import "MAVEABPerson.h"


@implementation MAVEABCollection

+ (id)createAndLoadAddressBookWithCompletionBlock:(void (^)(NSDictionary *))completionBlock {
    // TODO test with mocking out the load method
    MAVEABCollection *result = [[[self class] alloc] init];
    result.completionBlock = completionBlock;
    [result loadAllDataFromAddressBook];
    return result;
}

- (void)loadAllDataFromAddressBook {
    CFErrorRef abAccessErrorCF = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &abAccessErrorCF);
    if (abAccessErrorCF != nil) {
        NSError *abAccessError = (__bridge_transfer NSError *)abAccessErrorCF;
        if (!([abAccessError.domain isEqualToString:@"ABAddressBookErrorDomain"]
               && abAccessError.code == 1)) {
            NSLog(@"Unknown Error getting address book!");
        }
        self.completionBlock(nil);
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            NSArray *addressBookNS = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
            self.data = [[self class] copyEntireAddressBookToMAVEABPersonArray:addressBookNS];
        } else {
            NSLog(@"Not granted permission!");
        }
        if (addressBook != NULL) CFRelease(addressBook);
        self.completionBlock([self indexedDictionaryOfMAVEABPersons]);
    });
}

+ (NSArray *)copyEntireAddressBookToMAVEABPersonArray:(NSArray *)addressBook {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    MAVEABPerson *person = nil;
    for (NSUInteger i = 0; i < [addressBook count]; i++) {
        person = [[MAVEABPerson alloc] initFromABRecordRef:(__bridge ABRecordRef)addressBook[i]];
        if (person != nil) [result addObject:person];
    }
    // TODO: test that this gets called by putting a mock in the test for it
    [[self class] sortMAVEABPersonArray:result];
    return (NSArray *)result;
}

+ (void)sortMAVEABPersonArray:(NSMutableArray *)input {
    [input sortUsingSelector:@selector(compareNames:)];
}

- (NSDictionary *)indexedDictionaryOfMAVEABPersons {
    if (self.data == nil || [self.data count] == 0) {
        return nil;
    }
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    MAVEABPerson *person = nil;
    NSString *indexLetter = nil;
    for (NSUInteger i = 0; i < [self.data count]; i++) {
        // person should never be Nil or it wouldn't have been inserted into array
        person = self.data[i];
        // person firstLetter should never be nil since you can't create a person
        // with no first or last name
        indexLetter = [person firstLetter];
        if ([result objectForKey:indexLetter] == nil) {
            [result setValue:[[NSMutableArray alloc] init] forKey:indexLetter];
        }
        [[result objectForKey:indexLetter] addObject:person];
    }
    return result;
}

@end
