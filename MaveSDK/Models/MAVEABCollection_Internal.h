//
//  AddressBookDataCollection_Internal.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <AddressBook/AddressBook.h>

@interface MAVEABCollection ()

// Data format we store from the addres book is an NSArray * of MAVEABPerson records from
// the address book, sorted alphabetically.
@property NSArray *data;

@property (nonatomic, strong) void(^completionBlock)(NSDictionary *indexedData);

@property UITableView *viewToReload;

+ (void)sortMAVEABPersonArray:(NSMutableArray *)input;

@end