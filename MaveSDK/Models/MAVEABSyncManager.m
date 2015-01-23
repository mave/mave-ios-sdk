//
//  MAVEABSyncManager.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <zlib.h>
#import "MAVEABSyncManager.h"
#import "MAVEABPerson.h"

@implementation MAVEABSyncManager

- (instancetype)initWithAddressBookData:(NSArray *)personsArray {
    if (self = [super init]) {
        self.personsArray = [personsArray sortedArrayUsingSelector:@selector(compareRecordIDs:)];
    }
    return self;
}

@end