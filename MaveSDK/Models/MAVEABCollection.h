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
extern NSString * const MAVEABPermisssionStatusUnprompted;

@interface MAVEABCollection : NSObject

// When done loading the address book, will call the completion block with the
// indexed dictionary of people
+ (id)createAndLoadAddressBookWithCompletionBlock:(void(^)(NSDictionary *indexedData))completionBlock;

// mapping of ab status to states we care about, as a human-readable string
+ (NSString *)addressBookPermissionStatus;

// Take an array of MAVEABPerson objects and return a dict mapping the first letter
// of the sorted name to an array of MAVEABPerson objects beginning with that letter
- (NSDictionary *)indexedDictionaryOfMAVEABPersons;

@end
