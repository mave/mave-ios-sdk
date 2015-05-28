//
//  MAVEABUtils.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import "MAVEConstants.h"
#import "MAVEABUtils.h"
#import <AddressBook/AddressBook.h>
#import "MAVEABPerson.h"
#import "MAVEABTableViewController.h"

NSString * const MAVEABPermissionStatusAllowed = @"allowed";
NSString * const MAVEABPermissionStatusDenied = @"denied";
NSString * const MAVEABPermissionStatusUnprompted = @"unprompted";


@implementation MAVEABUtils

+ (NSString *)addressBookPermissionStatus {
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusAuthorized) {
        return MAVEABPermissionStatusAllowed;
    } else if (status == kABAuthorizationStatusNotDetermined) {
        return MAVEABPermissionStatusUnprompted;
    } else {  // there are two underlying statuses here
        return MAVEABPermissionStatusDenied;
    }
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

+ (UIImage *)getImageLookingUpPersonByRecordID:(ABRecordID)recordID {
    UIImage *image;
    ABAddressBookRef addressBook;
    CFDataRef dataCF;
    @try {
        if (![[self addressBookPermissionStatus] isEqualToString:MAVEABPermissionStatusAllowed]) {
            return nil;
        }
        if (!recordID) {
            return nil;
        }
        CFErrorRef accessErrorCF = NULL;
        addressBook = ABAddressBookCreateWithOptions(NULL, &accessErrorCF);
        if (accessErrorCF) {
            return nil;
        }
        // Use the dispatch semaphore to make the async method sync. Won't block b/c we know we have permission
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block BOOL granted = NO;
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool _granted, CFErrorRef error) {
            granted = _granted;
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));
        if (!granted || !addressBook) {
            return nil;
        }
        ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
        if (!recordRef) {
            return nil;
        }
        dataCF = ABPersonCopyImageData(recordRef);
        if (!dataCF || CFDataGetLength(dataCF) == 0) {
            return nil;
        }
        image = [UIImage imageWithData:(__bridge NSData *)dataCF];
    } @catch (NSException *exception) {
        image = nil;
    } @finally {
        if (addressBook) CFRelease(addressBook);
        if (dataCF) CFRelease(dataCF);
        return image;
    }
}

+ (void)sortMAVEABPersonArray:(NSMutableArray *)input {
    [input sortUsingSelector:@selector(compareNames:)];
}

+ (NSDictionary *)indexABPersonArrayForTableSections:(NSArray *)persons {
    if ([persons count] == 0) {
        return nil;
    }
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    MAVEABPerson *person = nil;
    NSString *indexLetter = nil;
    for (NSUInteger i = 0; i < [persons count]; i++) {
        // person can never be Nil or it wouldn't have been inserted into array
        person = persons[i];
        // person firstLetter can never be nil since you can't create a person
        // with no first or last name
        indexLetter = [person firstLetter];
        if ([result objectForKey:indexLetter] == nil) {
            [result setValue:[[NSMutableArray alloc] init] forKey:indexLetter];
        }
        [[result objectForKey:indexLetter] addObject:person];
    }
    return result;
}

+ (NSArray *)listOfABPersonsFromListOfHashedRecordIDTuples:(NSArray *)hridTuples
                                            andAllContacts:(NSArray *)persons {
    NSDictionary *index = [self indexABPersonArrayByHashedRecordID:persons];
    NSMutableArray *output = [[NSMutableArray alloc] initWithCapacity:[hridTuples count]];
    NSArray *tuple; NSString *hrid; MAVEABPerson *personTmp;
    for (id obj in hridTuples) {
        if (![obj isKindOfClass:[NSArray class]]) {
            continue;
        }
        tuple = obj;
        if ([tuple count] != 2) {
            continue;
        }
        hrid = [tuple objectAtIndex:0];
        personTmp = [index objectForKey:hrid];
        if (personTmp) {
            [output addObject:personTmp];
        }
    }
    return output;
}

+ (NSArray *)instancesOfABPersonsInList:(NSArray *)persons
                        fromAllContacts:(NSArray *)allContacts {
    NSDictionary *contactsIndexByHRID = [self indexABPersonArrayByHashedRecordID:allContacts];
    NSString *stringKey; MAVEABPerson *queriedPerson;
    NSMutableArray *output = [[NSMutableArray alloc] initWithCapacity:[persons count]];
    for (MAVEABPerson *person in persons) {
        stringKey = [NSString stringWithFormat:@"%llu", person.hashedRecordID];
        queriedPerson = [contactsIndexByHRID objectForKey:stringKey];
        if (queriedPerson) {
            [output addObject:queriedPerson];
        }
    }
    return [NSArray arrayWithArray:output];
}

+ (NSDictionary *)indexABPersonArrayByHashedRecordID:(NSArray *)persons {
    NSMutableDictionary *output = [[NSMutableDictionary alloc] initWithCapacity:[persons count]];
    NSString *stringKey;
    for (MAVEABPerson *person in persons) {
        stringKey = [NSString stringWithFormat:@"%llu", person.hashedRecordID];
        [output setObject:person forKey:stringKey];
    }
    return output;
}

+ (NSDictionary *)combineSuggested:(NSArray *)suggestedInvites intoABIndexedForTableSections:(NSDictionary *)indexedPersons {
    NSMutableDictionary *newData = [[NSMutableDictionary alloc] initWithCapacity:[indexedPersons count]+1];
    // Add the suggested invites to the new dictionary
    [newData setObject:suggestedInvites forKey:MAVESuggestedInvitesTableDataKey];

    // Add the existing invites to the new dictionary
    for (NSString *key in indexedPersons) {
        NSArray *listForKey = [indexedPersons objectForKey:key];
        [newData setObject:listForKey forKey:key];
    }
    return [[NSDictionary alloc] initWithDictionary:newData];
}

@end
