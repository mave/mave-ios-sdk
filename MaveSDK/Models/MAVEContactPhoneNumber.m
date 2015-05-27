//
//  MAVEContactPhoneNumber.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/26/15.
//
//

#import "MAVEContactPhoneNumber.h"
#import "MAVEABPerson.h"

@implementation MAVEContactPhoneNumber

+ (NSString *)ownTypeName {
    return @"phone";
}

- (NSString *)humanReadableValue {
    return [MAVEABPerson displayPhoneNumber:self.value];
}

- (NSString *)humanReadableLabel {
    if ([self.label isEqualToString:@"_$!<Main>!$_"]) {
        return @"main";
    } else if ([self.label isEqualToString:@"_$!<Mobile>!$_"]) {
        return @"cell";
    } else {
        return @"other";
    }
}

@end
