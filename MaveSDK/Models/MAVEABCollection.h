//
//  AddressBookDataCollection.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 9/25/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MAVEABCollection : NSObject

// When done loading the address book, will call the completion block with the
// indexed dictionary of people
+ (id)createAndLoadAddressBookWithCompletionBlock:(void(^)(NSDictionary *indexedData))completionBlock;

// Take an array of MAVEABPerson objects and return a dict mapping the first letter
// of the sorted name to an array of MAVEABPerson objects beginning with that letter
- (NSDictionary *)indexedDictionaryOfMAVEABPersons;

@end
