//
//  MAVEABTestDataFactory.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/26/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "MAVEABPerson.h"

// CF functions
ABRecordRef MAVECreateABRecordRefWithLastName(NSString *lastName);
ABRecordRef MAVECreateABRecordRef();

@interface MAVEABTestDataFactory : NSObject

+ (MAVEABPerson *)personWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;

@end
