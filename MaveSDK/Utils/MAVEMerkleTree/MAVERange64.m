//
//  MAVERange.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/13/15.
//
//

#import "MAVERange64.h"

MAVERange64 MAVEMakeRange64(uint64_t loc, uint64_t len) {
    MAVERange64 r;
    r.location = loc;
    r.length = len;
    return r;
}

 BOOL MAVELocationInRange64(uint64_t loc, MAVERange64 range) {
    return (!(loc < range.location) && (loc - range.location) < range.length) ? YES : NO;
}

extern NSString *MAVENSStringFromRange64(MAVERange64 range) {
    uint64_t first = range.location;
    uint64_t last = range.location + range.length;
    return [NSString stringWithFormat:@"{%llu, %llu}", first, last];
}
