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

+ (NSString *)interpolateTemplateString:(NSString *)templateString withUser:(MAVEUserData *)user {

    NSMutableDictionary *interpolationDict = [[NSMutableDictionary alloc] init];

    // All these user fields are NSStrings
    [interpolationDict setValue:user.userID forKey:@"user.userID"];
    [interpolationDict setValue:user.firstName forKey:@"user.firstName"];
    [interpolationDict setValue:user.lastName forKey:@"user.lastName"];
    [interpolationDict setValue:user.fullName forKey:@"user.fullName"];
    [interpolationDict setValue:user.promoCode forKey:@"user.promoCode"];
    NSDictionary *customData = user.customData;

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

+ (NSString *)appendLinkVariableToTemplateStringIfNeeded:(NSString *)templateString {
    NSString *LINKVAL = @"{{ link }}";
    // Shouldn't get empty case, but just in case return only link
    if ([templateString length] == 0) {
        return LINKVAL;
    }

    // to check if template already contains link, actually fill it in with a value that
    // won't exist in the string so we don't have to re-implement the logic to identify
    // a template variable, e.g. allowing both {{var}} and {{   var   }}.
    NSString *output = templateString;
    NSString *_tmp = [templateString templateFromDict:@{@"link": LINKVAL}];
    if (![_tmp containsString:LINKVAL]) {
        // template string has no link in it, so append one to the end, following a space
        NSString *lastLetter = [templateString substringFromIndex:[templateString length] - 1];
        if (![@[@" ", @"\n"] containsObject:lastLetter]) {
            output = [output stringByAppendingString:@" "];
        }
        output = [output stringByAppendingString:LINKVAL];
    }
    return output;
}

+ (NSString *)interpolateWithSingletonDataTemplateString:(NSString *)templateString {
    MAVEUserData *user = [MaveSDK sharedInstance].userData;
    return [self interpolateTemplateString:templateString withUser:user];
}


@end
