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
    [interpolationDict setValue:user.userID forKey:@"user.userID"];
    [interpolationDict setValue:user.firstName forKey:@"user.firstName"];
    [interpolationDict setValue:user.lastName forKey:@"user.lastName"];
    [interpolationDict setValue:user.fullName forKey:@"user.fullName"];

    NSString *namespacedKey, *key, *value;
    for (key in customData) {
        value = [customData valueForKey:key];
        namespacedKey = [@"customData." stringByAppendingString:key];
        [interpolationDict setValue:value forKey:namespacedKey];
    }

    NSString *output = [templateString templateFromDict:[NSDictionary dictionaryWithDictionary:interpolationDict]];
    return output;
}

+ (NSString *)interpolateWithSingletonDataTemplateString:(NSString *)templateString {
    MAVEUserData *user = [MaveSDK sharedInstance].userData;
    NSDictionary *customData = user.customData;
    return [self interpolateTemplateString:templateString withUser:user customData:customData];
}


@end
