//
//  AddressBookDataCollection_Internal.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <AddressBook/AddressBook.h>

@interface GRKABCollection ()

// Data format we store from the addres book is an NSArray * of GRKABPerson records from
// the address book, sorted alphabetically.
@property NSArray *data;

@property (nonatomic, strong) void(^completionBlock)(NSDictionary *indexedData);

@property UITableView *viewToReload;

// argument is an NSArray * of ABRecordRef pointers (output of ABAddressBookCopyArrayOfAllPeople)
// return value is an NSArray * of GRKABPerson objects that is sorted.
+ (NSArray *)copyEntireAddressBookToGRKABPersonArray:(NSArray *)addressBook;

+ (void)sortGRKABPersonArray:(NSMutableArray *)input;

@end