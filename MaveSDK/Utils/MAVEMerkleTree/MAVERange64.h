//
//  MAVERange.h
//  MaveSDK
//
//  Created by Danny Cosson on 2/13/15.
//
//

#import <Foundation/Foundation.h>

// We want to use ranges to handle the keys for the merkle tree data and we want the key sizes
// to be consistent in all cases (because we'll normally be e.g. syncing to a database) but NSRange
// uses NSUInteger which is 32-bit on iphone 5 and older. We'll explicitly use 64-bit.

typedef struct _MAVERange64 {
    uint64_t location;
    uint64_t length;
} MAVERange64;

extern MAVERange64 MAVEMakeRange64(uint64_t loc, uint64_t len);

extern BOOL MAVELocationInRange64(uint64_t loc, MAVERange64 range);

extern NSString *MAVENSStringFromRange64(MAVERange64 range);

