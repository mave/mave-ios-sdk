//
//  MAVEABPerson.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import "MAVEABPerson.h"
#import "MAVEMerkleTreeHashUtils.h"

const NSUInteger MAVEABPersonHashedRecordIDNumBytes = 6;

@implementation MAVEABPerson

- (instancetype) init {
    if (self = [super init]) {
        self.hashedRecordID = [[self class] computeHashedRecordID:0];
    }
    return self;
}

- (id)initFromABRecordRef:(ABRecordRef)record {
    if (self = [self init]) {
        @try {
            int32_t rid = ABRecordGetRecordID(record);
            self.recordID = rid;
            self.firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
            self.lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
            if (self.firstName == nil && self.lastName ==nil) {
                return nil;
            }
            [self setPhoneNumbersFromABRecordRef:record];
            if ([self.phoneNumbers count] == 0) {
                return nil;
            }
            self.emailAddresses = [[self class] emailAddressesFromABRecordRef:record];
        }
        @catch (NSException *exception) {
            self = nil;
        }
    }
    return self;
}

- (void)setRecordID:(NSInteger)recordID {
    // record ID is actually a 32 bit integer
    _recordID = recordID;
    self.hashedRecordID = [[self class] computeHashedRecordID:(int32_t)recordID];
}


///
/// Serialization methods for sending over wire
///
- (NSDictionary *)toJSONDictionary {
    return @{
        @"record_id": [[NSNumber alloc]initWithInteger:self.recordID],
        @"hashed_record_id": self.hashedRecordID,
        @"first_name": self.firstName ? self.firstName : [NSNull null],
        @"last_name": self.lastName ? self.lastName : [NSNull null],
        @"phone_numbers": [self.phoneNumbers count] > 0 ? self.phoneNumbers : @[],
        @"phone_number_labels": [self.phoneNumberLabels count] > 0 ? self.phoneNumberLabels : @[],
        @"email_addresses": [self.emailAddresses count] > 0 ? self.emailAddresses : @[],
    };
}

- (NSArray *)toJSONTupleArray {
    return @[
        @[@"record_id", [[NSNumber alloc]initWithInteger:self.recordID]],
        @[@"hashed_record_id", self.hashedRecordID],
        @[@"first_name", self.firstName ? self.firstName : [NSNull null]],
        @[@"last_name", self.lastName ? self.lastName : [NSNull null]],
        @[@"phone_numbers", [self.phoneNumbers count] > 0 ? self.phoneNumbers : @[]],
        @[@"phone_number_labels", [self.phoneNumberLabels count] > 0 ? self.phoneNumberLabels : @[]],
        @[@"email_addresses", [self.emailAddresses count] > 0 ? self.emailAddresses : @[]],
    ];
}

- (NSUInteger)merkleTreeDataKey {
    return [MAVEMerkleTreeHashUtils UInt64FromData:[MAVEMerkleTreeHashUtils dataFromHexString:self.hashedRecordID]];
}

- (id)merkleTreeSerializableData {
    return [self toJSONTupleArray];
}

- (void)setPhoneNumbersFromABRecordRef:(ABRecordRef) record{
    ABMultiValueRef phoneMultiValue = ABRecordCopyValue(record, kABPersonPhoneProperty);
    NSUInteger numPhones = ABMultiValueGetCount(phoneMultiValue);
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithCapacity:numPhones];
    NSMutableArray *phoneNumberLabels = [[NSMutableArray alloc] initWithCapacity:numPhones];
    
    NSString *pn; NSString *label;
    NSInteger insertIndex = 0;
    for (NSUInteger readIndex=0; readIndex < numPhones; readIndex++) {
        pn = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneMultiValue, readIndex);
        pn = [[self class] normalizePhoneNumber:pn];
        if (pn != nil) {
            [phoneNumbers insertObject:pn atIndex: insertIndex];
            label = (__bridge_transfer NSString *) ABMultiValueCopyLabelAtIndex(phoneMultiValue, readIndex);
            if (label == nil) {
                label = (__bridge_transfer NSString *) kABPersonPhoneOtherFAXLabel;
            }
            [phoneNumberLabels insertObject: label atIndex:insertIndex];
            insertIndex += 1;
        }
    }
    if (phoneMultiValue != NULL) CFRelease(phoneMultiValue);
    self.phoneNumbers = phoneNumbers;
    self.phoneNumberLabels = phoneNumberLabels;
}

+ (NSArray *)emailAddressesFromABRecordRef:(ABRecordRef)record {
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(record, kABPersonEmailProperty);
    NSUInteger numEmails = ABMultiValueGetCount(emailMultiValue);
    NSMutableArray *emailAddresses = [[NSMutableArray alloc] initWithCapacity:numEmails];
    for (NSUInteger i=0; i < numEmails; i++) {
        [emailAddresses
         insertObject:(__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailMultiValue, i)
         atIndex:i];
    }
    if (emailMultiValue != NULL) CFRelease(emailMultiValue);
    return (NSArray *)emailAddresses;
}

+ (NSString *)computeHashedRecordID:(uint32_t)recordID {
    NSData *recIDData = [MAVEMerkleTreeHashUtils dataFromInt32:recordID];
    NSData *hashedTruncatedData = [MAVEMerkleTreeHashUtils md5Hash:recIDData
                                                  truncatedToBytes:MAVEABPersonHashedRecordIDNumBytes];
    return [MAVEMerkleTreeHashUtils hexStringFromData:hashedTruncatedData];
}

- (NSString *)firstLetter {
    NSString *compName = [self nameForCompareNames];
    NSString *letter = [compName substringToIndex:1];
    letter = [letter uppercaseString];
    return letter;
}

- (NSString *)fullName {
    NSString *name = nil;
    if (self.firstName != nil && self.lastName != nil) {
        name = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    } else if (self.firstName != nil) {
        name = self.firstName;
    } else if (self.lastName != nil) {
        name = self.lastName;
    }
    return name;
}

+ (NSString *)normalizePhoneNumber:(NSString *)phoneNumber {
    NSString * numOnly = [phoneNumber
                          stringByReplacingOccurrencesOfString:@"[^0-9]"
                          withString:@""
                          options:NSRegularExpressionSearch
                          range:NSMakeRange(0, [phoneNumber length])];
    if ([numOnly length] == 10) {
        numOnly = [@"1" stringByAppendingString:numOnly];
    }
    // the character "1"s unichar value is 49
    if (! ([numOnly length] == 11 && [numOnly characterAtIndex:0] == 49) ) {
        numOnly = nil;
    }
    return numOnly;
}

// For now, phone is required so this will always return exactly one phone
// number that we should send the invite to
- (NSString *)bestPhone {
    NSString *val = nil;
    unsigned long numPhones = [self.phoneNumbers count];
    int i;
    // Check for mobile
    for (i=0; i < numPhones; i++) {
        if ([self.phoneNumberLabels[i] isEqual:@"_$!<Mobile>!$_"]) {
            val = self.phoneNumbers[i];
            break;
        }
    }
    // If not found check for Main
    if (val == nil) {
        for (i=0; i < numPhones; i++) {
            if ([self.phoneNumberLabels[i] isEqual:@"_$!<Main>!$_"]) {
                val = self.phoneNumbers[i];
                break;
            }
        }
    }
    // Otherwise use the first one
    if (val == nil && numPhones > 0) {
        val = self.phoneNumbers[0];
    }
    return val;
}

+ (NSString *)displayPhoneNumber:(NSString *)phoneNumber {
    NSString *areaCode = [phoneNumber substringWithRange:NSMakeRange(1, 3)];
    NSString *first3 = [phoneNumber substringWithRange:NSMakeRange(4, 3)];
    NSString *last4 = [phoneNumber substringWithRange:NSMakeRange(7, 4)];
    return [NSString stringWithFormat:@"(%@)\u00a0%@-%@", areaCode, first3, last4];
}

- (NSComparisonResult)compareNames:(MAVEABPerson *)otherPerson {
    return [[self nameForCompareNames] compare:[otherPerson nameForCompareNames]];
}

- (NSString *)nameForCompareNames {
    NSString * fn = self.firstName;
    if (fn == nil) fn = @"";
    NSString *ln = self.lastName;
    if (ln == nil) ln = @"";
    return [NSString stringWithFormat:@"%@%@",fn,ln];
}

- (NSComparisonResult)compareRecordIDs:(MAVEABPerson *)otherPerson {
    if (self.recordID > otherPerson.recordID) {
        return NSOrderedDescending;
    } else if (self.recordID == otherPerson.recordID) {
        return NSOrderedSame;
    } else {
        return NSOrderedAscending;
    }
}

- (NSComparisonResult)compareHashedRecordIDs:(MAVEABPerson *)otherPerson {
    return [self.hashedRecordID compare:otherPerson.hashedRecordID];
}

@end
