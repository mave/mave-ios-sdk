//
//  AddressBookDataCollection.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
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
// of the sorted name to an array of MAVEABPerson objects beginning with that letter.
// This way of indexing is for displaying them in a table view alphabetically with
// sections corresponding to first letter of name.
+ (NSDictionary *)indexABPersonArrayForTableSections:(NSArray *)persons;

// Take an array of MAVEABPerson objects and return a dict mapping each hashed_record_id
// to the MAVEABPerson object.
// This way of indexing lets us easily turn a list of hashed_records_ids (e.g. one returned
// by the server) into a list of records


// Convert an array of hashed record id's into an array of MAVEABPersons by looking up
// each one in the full address book.
// The following method is a helper to build an index for this one
+ (NSArray *)listOfABPersonsFromListOfHashedRecordIDTuples:(NSArray *)hridTuples
                                       andAllContacts:(NSArray *)persons;

// Given a list of ABPerson objects, find the exact instances as found in list of all contacts
// This is useful e.g. if we got a serialized list of suggestions from the server that we
// convert into MAVEABPerson objects, when merging it into the contacts table those records will
// not show up as duplicates unless they're pointers to the same objects in our contacts table.
// So call this method to return the object, matched on hashed record id.
+ (NSArray *)instancesOfABPersonsInList:(NSArray *)persons
                        fromAllContacts:(NSArray *)allContacts;

+ (NSDictionary *)indexABPersonArrayByHashedRecordID:(NSArray *)persons;

// Merge a list of suggested people into the dictionary of data for the address book table
// (dict mapping each first letter to a list of MAVEABPersons).
+ (NSDictionary *)combineSuggested:(NSArray *)suggestedInvites
     intoABIndexedForTableSections:(NSDictionary *)indexedPersons;

// Sorter
+ (void)sortMAVEABPersonArray:(NSMutableArray *)input;

@end
