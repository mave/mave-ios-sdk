//
//  MAVEABPerson.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface MAVEABPerson : NSObject

// A Person object that is much simpler than an ABRecordRef - has just the fields we care about
// and is an NSObject with helper methods to access fields we want.

@property (nonatomic, assign) NSInteger recordID;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSArray *phoneNumbers;   // Array of NSStrings
@property (nonatomic, strong) NSArray *phoneNumberLabels;  //Array of NSStrings of localized labels
@property (nonatomic, strong) NSArray *emailAddresses; // Array of NSStrings

@property BOOL selected;

// initFromABRecordRef factory creates and does some validation
//   - one of firstName, lastName are required, if both are missing returns nil
//   - all other fields are optional
- (id)initFromABRecordRef:(ABRecordRef)record;

// Returns a comparison result, used to sort people by name. Sorts by last name first
// if it exists, otherwise first name
- (NSComparisonResult)compareNames:(MAVEABPerson *)otherPerson;

// Returns the first letter, capitalized, of the name being used for sorting
// (last name if it exists, otherwise first name)
- (NSString *)firstLetter;

- (NSString *)fullName;

// Returns the mobile or main phone or the first one in the list if there are phones, otherwise nil
- (NSString *)bestPhone;

+ (NSString *)normalizePhoneNumber:(NSString *)phoneNumber;

// Takes an 11-digit US phone number beginning with 1 and returns in pretty human readable format
+ (NSString *)displayPhoneNumber:(NSString *)phoneNumber;

// Private
- (void)setPhoneNumbersFromABRecordRef:(ABRecordRef)record;
+ (NSArray *)emailAddressesFromABRecordRef:(ABRecordRef)record;
- (NSString *)nameForCompareNames;

@end

@interface MAVEABPersonRow :MAVEABPerson

@property BOOL selected;

@end
