//
//  MAVEABPerson.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "MAVEMerkleTree.h"
#import "MAVEContactPhoneNumber.h"
#import "MAVEContactEmail.h"

typedef NS_ENUM(NSInteger, MAVEInviteSendingStatus) {
    MAVEInviteSendingStatusUnsent,
    MAVEInviteSendingStatusSending,
    MAVEInviteSendingStatusSent,
};

@interface MAVEABPerson : NSObject<MAVEMerkleTreeDataItem>

// A Person object that is much simpler than an ABRecordRef - has just the fields we care about
// and is an NSObject with helper methods to access fields we want.

@property (nonatomic, assign) int32_t recordID;
@property (nonatomic, assign) uint64_t hashedRecordID;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) UIImage *picture;
@property (nonatomic, strong) NSArray *phoneNumbers;   // Array of NSStrings
@property (nonatomic, strong) NSArray *phoneNumberLabels;  //Array of NSStrings of localized labels
@property (nonatomic, strong) NSArray *emailAddresses; // Array of NSStrings
@property (nonatomic, strong) NSArray *phoneObjects; // Array of MAVEContactPhones
@property (nonatomic, strong) NSArray *emailObjects; // Array of MAVEContactEmails

// This field is true if the contact as returned from the API as a suggested invite
@property (nonatomic, assign) BOOL isSuggestedContact;
// This field is only true if the contact was clicked on in the top
// suggestions section of the contact list, if the contact was
// searched for alphabetically and selected this will be false,
// even if the contact was a suggested invite.
@property (nonatomic, assign) BOOL selectedFromSuggestions;

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) MAVEInviteSendingStatus sendingStatus;

// initFromABRecordRef factory creates and does some validation
//   - one of firstName, lastName are required, if both are missing returns nil
//   - all other fields are optional
- (id)initFromABRecordRef:(ABRecordRef)record;

// Export fields to an NSDictionary, using only basic types so it can be JSON encoded
- (NSDictionary *)toJSONDictionary;
// Another serialization method, include suggested invites metadata
- (NSDictionary *)toJSONDictionaryIncludingSuggestionsMetadata;

// This is a hashable format that can be encoded in json, instead of encoding the properties
// as a key-value dictionary (which is unordered) we encode them as an array of (key, value)
// consistently ordered tuples (using an NSArray of length 2 as the tuple).
// This makes the serialized JSON representation hashable.
- (NSArray *)toJSONTupleArray;

// Returns a comparison result, used to sort people by name. Sorts by last name first
// if it exists, otherwise first name
- (NSComparisonResult)compareNames:(MAVEABPerson *)otherPerson;

// Compare people by record ID's
- (NSComparisonResult)compareRecordIDs:(MAVEABPerson *)otherPerson;
- (NSComparisonResult)compareHashedRecordIDs:(MAVEABPerson *)otherPerson;

// Helper to correctly format the hashed record ID for format we store, which is
// first 6 bytes of md5 of big-endian representation of record id, encoded as a hex string.
+ (uint64_t)computeHashedRecordID:(ABRecordID)recordID;

// Returns the first letter, capitalized, of the name being used for sorting
// (last name if it exists, otherwise first name)
- (NSString *)firstLetter;
- (NSString *)fullName;
- (NSString *)initials;

// Returns the mobile or main phone or the first one in the list if there are phones, otherwise nil
- (NSString *)bestPhone;
// Return a list of contact identifiers for this user, and another method to get a sorted list
- (NSArray *)allContactIdentifiers;
- (NSArray *)rankedContactIdentifiersIncludeEmails:(BOOL)includeEmails includePhones:(BOOL)includePhones;
- (NSArray *)selectedContactIdentifiers;

- (BOOL)isAtLeastOneContactIdentifierSelected;
- (void)selectTopContactIdentifierIfNoneSelected;

+ (NSString *)normalizePhoneNumber:(NSString *)phoneNumber;

// Takes an 11-digit US phone number beginning with 1 and returns in pretty human readable format
+ (NSString *)displayPhoneNumber:(NSString *)phoneNumber;

// Private
- (void)setPhoneNumbersFromABRecordRef:(ABRecordRef)record;
- (void)setEmailAddressesFromABRecordRef:(ABRecordRef) record;
- (NSString *)nameForCompareNames;

@end
