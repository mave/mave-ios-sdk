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

NSString * const MAVEContactPhoneLabeliPhone = @"iPhone";
NSString * const MAVEContactPhoneLabelMobile = @"_$!<Mobile>!$_";
NSString * const MAVEContactPhoneLabelMain = @"_$!<Main>!$_";
NSString * const MAVEContactPhoneLabelHome = @"_$!<Home>!$_";
NSString * const MAVEContactPhoneLabelWork = @"_$!<Work>!$_";
NSString * const MAVEContactPhoneLabelOther = @"_$!<OtherFAX>!$_";

NSString * const MAVEContactPhoneHumanReadableLabeliPhone = @"iPhone";
NSString * const MAVEContactPhoneHumanReadableLabelMobile = @"cell";
NSString * const MAVEContactPhoneHumanReadableLabelMain = @"main";
NSString * const MAVEContactPhoneHumanReadableLabelHome = @"home";
NSString * const MAVEContactPhoneHumanReadableLabelWork = @"work";
NSString * const MAVEContactPhoneHumanReadableLabelOther = @"other";

@implementation MAVEContactPhoneNumber

- (instancetype)initWithValue:(NSString *)value andLabel:(NSString *)label {
    self = [super initWithValue:value andLabel:label];
    if (self) {
        if (![self.label isEqualToString:MAVEContactPhoneLabeliPhone] &&
            ![self.label isEqualToString:MAVEContactPhoneLabelMobile] &&
            ![self.label isEqualToString:MAVEContactPhoneLabelMain] &&
            ![self.label isEqualToString:MAVEContactPhoneLabelHome] &&
            ![self.label isEqualToString:MAVEContactPhoneLabelWork] &&
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
    if ([self.label isEqualToString:MAVEContactPhoneLabeliPhone]) {
        return MAVEContactPhoneHumanReadableLabeliPhone;
    } else if ([self.label isEqualToString:MAVEContactPhoneLabelMobile]) {
        return MAVEContactPhoneHumanReadableLabelMobile;
    } else if ([self.label isEqualToString:MAVEContactPhoneLabelMain]) {
        return MAVEContactPhoneHumanReadableLabelMain;
    } else if ([self.label isEqualToString:MAVEContactPhoneLabelHome]) {
        return MAVEContactPhoneHumanReadableLabelHome;
    } else if ([self.label isEqualToString:MAVEContactPhoneLabelWork]) {
        return MAVEContactPhoneHumanReadableLabelWork;
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
    // iPhone is best
    if ([self.label isEqualToString:MAVEContactPhoneLabeliPhone]) {
        return NSOrderedAscending;
    } else if ([otherPhone.label isEqualToString:MAVEContactPhoneLabeliPhone]) {
        return NSOrderedDescending;
    // then Mobile
    } else if ([self.label isEqualToString:MAVEContactPhoneLabelMobile]) {
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
