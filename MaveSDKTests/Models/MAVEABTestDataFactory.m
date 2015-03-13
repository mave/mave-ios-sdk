//
//  MAVEABTestDataFactory.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/26/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "MAVEABPerson.h"
#import "MAVEABTestDataFactory.h"
#include <stdlib.h>
#import "Gizou.h"


ABRecordRef MAVECreateABRecordRefWithLastName(NSString *lastName) {
    ABRecordRef rec = ABPersonCreate();

    CFStringRef firstNameCF = CFBridgingRetain([GZNames firstName]);
    ABRecordSetValue(rec, kABPersonFirstNameProperty, firstNameCF, nil);
    if (firstNameCF != nil) CFRelease(firstNameCF);

    CFStringRef lastNameCF = CFBridgingRetain(lastName);
    ABRecordSetValue(rec, kABPersonLastNameProperty, lastNameCF, nil);
    if (lastNameCF != nil) CFRelease(lastNameCF);

    ABMutableMultiValueRef pnmv = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    CFStringRef phoneNumberCF = CFBridgingRetain([GZPhoneNumbers phoneNumber]);
    ABMultiValueAddValueAndLabel(pnmv, phoneNumberCF, kABPersonPhoneMobileLabel, NULL);
    if (phoneNumberCF != nil) CFRelease(phoneNumberCF);
    ABRecordSetValue(rec, kABPersonPhoneProperty, pnmv, nil);
    if (pnmv != nil) CFRelease(pnmv);

    ABMutableMultiValueRef emv = ABMultiValueCreateMutable(kABPersonEmailProperty);
    CFStringRef emailCF = CFBridgingRetain([GZInternet email]);
    ABMultiValueAddValueAndLabel(emv, emailCF, kABOtherLabel, NULL);
    if (emailCF != nil) CFRelease(emailCF);
    ABRecordSetValue(rec, kABPersonEmailProperty, emv, nil);
    if (emv != nil) CFRelease(emv);

    return rec;
}

ABRecordRef MAVECreateABRecordRef() {
    NSString *randomLastName = [GZNames lastName];
    return MAVECreateABRecordRefWithLastName(randomLastName);
}



@implementation MAVEABTestDataFactory

+ (MAVEABPerson *)personWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    u_int32_t maxRecordID = 1 + (int)(pow(2, 32) - 2);
    p.recordID = arc4random_uniform(maxRecordID);
    p.firstName = firstName; p.lastName = lastName;
    return p;
}

@end
