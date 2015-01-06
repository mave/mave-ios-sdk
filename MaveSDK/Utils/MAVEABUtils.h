//
//  AddressBookDataCollection.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

extern NSString * const MAVEABPermissionStatusAllowed;
extern NSString * const MAVEABPermissionStatusDenied;
extern NSString * const MAVEABPermissionStatusUnprompted;

@interface MAVEABUtils : NSObject

// mapping of ab status to states we care about, as a human-readable string
+ (NSString *)addressBookPermissionStatus;

// argument is an NSArray * of ABRecordRef pointers (output of ABAddressBookCopyArrayOfAllPeople)
// return value is an NSArray * of MAVEABPerson objects that is sorted.
+ (NSArray *)copyEntireAddressBookToMAVEABPersonArray:(NSArray *)addressBook;

// Take an array of MAVEABPerson objects and return a dict mapping the first letter
// of the sorted name to an array of MAVEABPerson objects beginning with that letter
+ (NSDictionary *)indexedDictionaryFromMAVEABPersonArray:(NSArray *)persons;

// Sorter
+ (void)sortMAVEABPersonArray:(NSMutableArray *)input;

@end
