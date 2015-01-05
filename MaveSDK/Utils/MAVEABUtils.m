//
//  MAVEABUtils.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "MAVEConstants.h"
#import "MAVEABUtils.h"
#import <AddressBook/AddressBook.h>
#import "MAVEABPerson.h"

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

+ (void)sortMAVEABPersonArray:(NSMutableArray *)input {
    [input sortUsingSelector:@selector(compareNames:)];
}

+ (NSDictionary *)indexedDictionaryFromMAVEABPersonArray:(NSArray *)persons {
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

@end
