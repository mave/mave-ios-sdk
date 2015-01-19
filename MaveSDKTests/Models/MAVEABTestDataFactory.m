//
//  MAVEABTestDataFactory.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/26/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "MAVEABPerson.h"
#import "MAVEABTestDataFactory.h"
#include <stdlib.h>
#import "Gizou.h"

@implementation MAVEABTestDataFactory

+ (MAVEABPerson *)personWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    u_int32_t maxRecordID = 1 + (int)(pow(2, 32) - 2);
    p.recordID = arc4random_uniform(maxRecordID);
    p.firstName = firstName; p.lastName = lastName;
    return p;
}

+ (ABRecordRef)generateABRecordRef {
    NSString *randomLastName = [GZNames lastName];
    return [[self class]generateABRecordRefWithLastName:randomLastName];
}

+ (ABRecordRef)generateABRecordRefWithLastName:(NSString *)lastName {
    ABRecordRef rec = ABPersonCreate();
    ABRecordSetValue(rec, kABPersonFirstNameProperty, CFBridgingRetain([GZNames firstName]), nil);
    ABRecordSetValue(rec, kABPersonLastNameProperty, CFBridgingRetain(lastName), nil);
    
    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(pnmv, CFBridgingRetain([GZPhoneNumbers phoneNumber]), kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    
    ABMutableMultiValueRef emv = ABMultiValueCreateMutable(kABPersonEmailProperty);
    ABMultiValueAddValueAndLabel(emv, CFBridgingRetain([GZInternet email]), kABOtherLabel, NULL);
    ABRecordSetValue(rec, kABPersonEmailProperty, emv, nil);
    return rec;
}

+ (NSArray *)generateAddressBookOfSize:(NSUInteger)size {
    NSMutableArray *addressBook = [[NSMutableArray alloc] initWithCapacity:size];
    for (NSUInteger i = 0; i < size; i++) {
        id item = [[self class] generateABRecordRef];
        [addressBook insertObject: item atIndex: i];
    }
    return (NSArray *)addressBook;
}

@end
