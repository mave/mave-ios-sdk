//
//  MAVEContactPhoneNumber.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/26/15.
//
//

#import "MAVEContactPhoneNumber.h"
#import "MAVEABPerson.h"
#import "MAVEConstants.h"

NSString * const MAVEContactPhoneLabelMain = @"_$!<Main>!$_";
NSString * const MAVEContactPhoneLabelMobile = @"_$!<Mobile>!$_";
NSString * const MAVEContactPhoneLabelOther = @"_$!<Other>!$_";

NSString * const MAVEContactPhoneHumanReadableLabelMain = @"main";
NSString * const MAVEContactPhoneHumanReadableLabelMobile = @"cell";
NSString * const MAVEContactPhoneHumanReadableLabelOther = @"other";

@implementation MAVEContactPhoneNumber

- (instancetype)initWithValue:(NSString *)value andLabel:(NSString *)label {
    self = [super initWithValue:value andLabel:label];
    if (self) {
        if (![self.label isEqualToString:MAVEContactPhoneLabelMain] &&
            ![self.label isEqualToString:MAVEContactPhoneLabelMobile] &&
            ![self.label isEqualToString:MAVEContactPhoneLabelOther]) {
            MAVEDebugLog(@"Initialized phone number with invalid label %@, falling back to %@", self.label, MAVEContactPhoneLabelOther);
            self.label = MAVEContactPhoneLabelOther;
        }
    }
    return self;
}

+ (NSString *)ownTypeName {
    return @"phone";
}

- (NSString *)humanReadableValue {
    return [MAVEABPerson displayPhoneNumber:self.value];
}

- (NSString *)humanReadableLabel {
    if ([self.label isEqualToString:MAVEContactPhoneLabelMain]) {
        return MAVEContactPhoneHumanReadableLabelMain;
    } else if ([self.label isEqualToString:MAVEContactPhoneLabelMobile]) {
        return MAVEContactPhoneHumanReadableLabelMobile;
    } else {
        return MAVEContactPhoneHumanReadableLabelOther;
    }
}

- (NSComparisonResult)compareContactIdentifiers:(MAVEContactIdentifierBase *)other {
    // Phone is preferred type, so if other is not a phone it's ranked lower
    if (![other isKindOfClass:[MAVEContactPhoneNumber class]]) {
        return NSOrderedAscending;
    }
    MAVEContactPhoneNumber *otherPhone = (MAVEContactPhoneNumber *)other;

    // If labels are the same, no preference
    if ([self.label isEqualToString:otherPhone.label]) {
        return NSOrderedSame;
    }

    // Here both are phones and labels differ, so one is better than the other
    // Cell is best
    if ([self.label isEqualToString:MAVEContactPhoneLabelMobile]) {
        return NSOrderedAscending;
    } else if ([otherPhone.label isEqualToString:MAVEContactPhoneLabelMobile]) {
        return NSOrderedDescending;
    // then Main
    } else if ([self.label isEqualToString:MAVEContactPhoneLabelMain]) {
        return NSOrderedAscending;
    } else if ([otherPhone.label isEqualToString:MAVEContactPhoneLabelMain]) {
        return NSOrderedDescending;
    // Otherwise no preference
    } else {
        return NSOrderedSame;
    }
}

@end
