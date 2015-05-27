//
//  MAVEContactEmail.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/27/15.
//
//

#import "MAVEContactEmail.h"
#import "MAVEContactPhoneNumber.h"

@implementation MAVEContactEmail

+ (NSString *)ownTypeName {
    return @"email";
}

- (NSComparisonResult)compareContactIdentifiers:(MAVEContactIdentifierBase *)other {
    // phones are before emails
    if ([other isKindOfClass:[MAVEContactPhoneNumber class]]) {
        return NSOrderedDescending;
    }
    // phones & emails are only types for now, so otherwise they're equal
    return NSOrderedSame;
}

@end
