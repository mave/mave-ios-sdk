//
//  GRKABTestDataFactory.h
//  GrowthKitDevApp
//
//  Created by dannycosson on 9/26/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "GRKABPerson.h"

@interface GRKABTestDataFactory : NSObject

+ (GRKABPerson *)personWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;
+ (ABRecordRef)generateABRecordRef;
+ (ABRecordRef)generateABRecordRefWithLastName:(NSString *)lastName;

// This is not an ABAddressBookRef object because that's basically a singleton tied to the
// global address book data on the device. This returns an NSArray * of ABRecordRef items,
// same as what gets returned by ABAddressBookCopyArrayOfAllPeople()
+ (NSArray *)generateAddressBookOfSize:(NSUInteger)size;

@end
