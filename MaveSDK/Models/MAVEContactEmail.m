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

    // Here both are emails, gmail should be ranked highest of emails
//    MAVEContactEmail *otherEmail = (MAVEContactEmail *)other;
//    NSArray *tmp; NSString *ownDomain; NSString *otherDomain;
//    tmp = [self.value componentsSeparatedByString:@"@"];
//    if (
    return NSOrderedSame;
}

- (NSString *)domain {
    NSArray *tmp = [self.value componentsSeparatedByString:@"@"];
    if ([tmp count] < 2) {
        return nil;
    }
    NSString *domainVal = [tmp objectAtIndex:1];
    if (!domainVal || [domainVal length] == 0) {
        return nil;
    }
    return domainVal;
}

- (BOOL)isGmail {
    return [[self domain] isEqualToString:@"gmail.com"];
}

@end
