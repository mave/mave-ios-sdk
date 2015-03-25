//
//  MAVETemplatingUtils.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/24/15.
//
//

#import "MAVETemplatingUtils.h"
#import "MaveSDK.h"
#import "CCTemplate.h"

@implementation MAVETemplatingUtils

+ (NSString *)interpolateTemplateString:(NSString *)templateString withUser:(MAVEUserData *)user customData:(NSDictionary *)customData {

    NSMutableDictionary *interpolationDict = [[NSMutableDictionary alloc] init];

    // All these user fields are NSStrings
    [interpolationDict setValue:user.userID forKey:@"user.userID"];
    [interpolationDict setValue:user.firstName forKey:@"user.firstName"];
    [interpolationDict setValue:user.lastName forKey:@"user.lastName"];
    [interpolationDict setValue:user.fullName forKey:@"user.fullName"];

    NSString *namespacedKey, *key, *stringValue;
    for (key in customData) {
        if (![key isKindOfClass:[NSString class]]) {
            continue;
        }
        stringValue = [self convertValueToString:[customData objectForKey:key]];
        if (!stringValue) {
            continue;
        }
        namespacedKey = [@"customData." stringByAppendingString:key];
        [interpolationDict setValue:stringValue forKey:namespacedKey];
    }

    NSString *output = [templateString templateFromDict:[NSDictionary dictionaryWithDictionary:interpolationDict]];
    return output;
}

+ (NSString *)convertValueToString:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)value) stringValue];
    }
    if (value == (id)[NSNull null]) {
        return @"<null>";
    }
    return nil;
}

+ (NSString *)interpolateWithSingletonDataTemplateString:(NSString *)templateString {
    MAVEUserData *user = [MaveSDK sharedInstance].userData;
    NSDictionary *customData = user.customData;
    return [self interpolateTemplateString:templateString withUser:user customData:customData];
}


@end
