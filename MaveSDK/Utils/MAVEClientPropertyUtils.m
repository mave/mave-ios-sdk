//
//  MAVEClientPropertyUtils.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/30/14.
//
//

#include <sys/sysctl.h>

#import "MAVEClientPropertyUtils.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVEIDUtils.h"
#import "MAVENameParsingUtils.h"


@implementation MAVEClientPropertyUtils

// This is the app name displayed e.g. on the homescreen & in settings
// Apple uses the display name if set, if not then the bundle name
+ (NSString *)appName {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    return appName;
}

+ (NSString *)appRelease {
    return  [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

+ (NSString *)carrier {
    NSString *_carrier = [[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider].carrierName;
    if (!_carrier) {
        _carrier = @"Unknown";
    }
    return _carrier;
}

+ (NSString *)countryCode {
    return [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
}

+ (NSString *)deviceName {
    return [UIDevice currentDevice].name;
}

+ (NSString *)deviceUsersFullName {
    NSString *deviceName = [self deviceName];
    NSString *firstName, *lastName;
    [MAVENameParsingUtils fillFirstName:&firstName
                               lastName:&lastName
                         fromDeviceName:deviceName];
    return [MAVENameParsingUtils joinFirstName:firstName andLastName:lastName];
}

+ (NSString *)deviceUsersFirstName {
    NSString *firstName, *unused;
    [MAVENameParsingUtils fillFirstName:&firstName
                               lastName:&unused
                         fromDeviceName:[self deviceName]];
    return firstName;
}

+ (NSString *)deviceUsersLastName {
    NSString *unused, *lastName;
    [MAVENameParsingUtils fillFirstName:&unused
                               lastName:&lastName
                         fromDeviceName:[self deviceName]];
    return lastName;
}

+ (NSString *)language {
    return [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleLanguageCode];
}

+ (NSString *)appDeviceID {
    return [MAVEIDUtils loadOrCreateNewAppDeviceID];
}

+ (NSString *)maveVersion {
    return MAVESDKVersion;
}

+ (NSString *)manufacturer {
    return @"Apple";
}

+ (NSString *)model
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char answer[size];
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = @(answer);
    return results;
}

+ (NSString *)os {
    return [[UIDevice currentDevice] systemName];
}

+ (NSString *)osVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)userAgentDeviceString {
    UIDevice *device = [UIDevice currentDevice];
    NSString *iosVersionStr =
    [device.systemVersion stringByReplacingOccurrencesOfString:@"."
                                                    withString:@"_"];
    return [NSString stringWithFormat:@"(iPhone; CPU iPhone OS %@ like Mac OS X)",
            iosVersionStr];
}

+ (NSString *)formattedScreenSize {
    CGSize size = [UIScreen mainScreen].bounds.size;
    long w = (long)round(size.width);
    long h = (long)round(size.height);
    if (w > h) {
        long tmp = w;
        w = h;
        h = tmp;
    }
    return [NSString stringWithFormat:@"%ldx%ld", w, h];
}



+ (NSString *)encodedAutomaticClientProperties {
    // use setValue:forKey: which will  omit setting the object in the
    // dictionary if nil, just in case a nil value sneaks in somehow
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:[self appDeviceID] forKey: @"app_device_id"];
    [properties setValue:[self appRelease] forKey: @"app_release"];
    [properties setValue:[self appVersion] forKey: @"app_version"];
    [properties setValue:[self carrier] forKey: @"carrier"];
    [properties setValue:[self countryCode] forKey: @"device_country"];
    [properties setValue:[self language] forKey: @"device_language"];
    [properties setValue:[self deviceName] forKey:@"device_name"];
    [properties setValue:[self deviceUsersFullName] forKey:@"device_name_parsed"];
    [properties setValue:[self maveVersion] forKey: @"mave_version"];
    [properties setValue:[self manufacturer] forKey: @"manufacturer"];
    [properties setValue:[self model] forKey: @"model"];
    [properties setValue:[self os] forKey: @"os"];
    [properties setValue:[self osVersion] forKey: @"osVersion"];

    return [self base64EncodeDictionary:properties];
}


+ (NSString *)encodedContextProperties {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    NSString *propertyVal;

    // Set in the explicitly-set-by-application invite_context value
    propertyVal = [MaveSDK sharedInstance].inviteContext;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"invite_context"];

    // Set the user id
    propertyVal = [MaveSDK sharedInstance].userData.userID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"user_id"];

    // Also fill in the template ids for all remote configuration data objects.
    // If any are nil, set to NSNull so the json key will still be created with "null"
    // Note that these could all be the default value of "0" or the previously-saved value
    // if the remote configuration hasn't returned yet (e.g. the track app open request).
    MAVERemoteConfiguration *remoteConfig = [MaveSDK sharedInstance].remoteConfigurationBuilder.object;
    propertyVal = remoteConfig.contactsPrePrompt.templateID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"contacts_pre_permission_prompt_template_id"];

    propertyVal = remoteConfig.contactsInvitePage.templateID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"contacts_invite_page_template_id"];

    propertyVal = remoteConfig.customSharePage.templateID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"share_page_template_id"];

    propertyVal = remoteConfig.serverSMS.templateID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"server_sms_template_id"];

    propertyVal = remoteConfig.clientSMS.templateID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"client_sms_template_id"];

    propertyVal = remoteConfig.clientEmail.templateID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"client_email_template_id"];

    propertyVal = remoteConfig.facebookShare.templateID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"facebook_share_template_id"];

    propertyVal = remoteConfig.twitterShare.templateID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"twitter_share_template_id"];

    propertyVal = remoteConfig.clipboardShare.templateID;
    if (!propertyVal) {propertyVal = (NSString *)[NSNull null];}
    [properties setValue:propertyVal forKey:@"clipboard_share_template_id"];

    return [self base64EncodeDictionary:properties];
}



+ (NSString *)base64EncodeDictionary:(NSDictionary *)dict {
    // Base64 encode the dictionary
    NSError *serializationError;
    NSData *jsonString = [NSJSONSerialization dataWithJSONObject:dict
                                                         options:0
                                                           error:&serializationError];
    if (serializationError) {
        MAVEErrorLog(@"Error serializing json in base64 helper: %@: %@", serializationError, dict);
        jsonString = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [jsonString base64EncodedStringWithOptions:0];
}

+ (NSDictionary *)base64DecodeJSONString:(NSString *)base64String {
    NSData *jsonData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSError *serializationError;
    NSDictionary *output = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serializationError];
    if (serializationError) {
        MAVEErrorLog(@"ERROR deserializing json in base64 helper: %@: %@", serializationError, jsonData);
        output = @{};
    }
    return output;
}

+ (NSString *)urlSafeBase64EncodeAndStripData:(NSData *)value {
    NSString *output = [value base64EncodedStringWithOptions:0];
    if ([output length] == 0) {
        return @"";
    }

    // replace / and + with _ and -
    output = [output stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    output = [output stringByReplacingOccurrencesOfString:@"+" withString:@"-"];

    // Strip trailing '=' chars
    NSString *lastLetter;
    while (YES) {
        lastLetter = [output substringFromIndex:([output length]-1)];
        if ([lastLetter isEqualToString:@"="]) {
            output = [output substringToIndex:([output length]-1)];
        } else {
            break;
        }
    }
    return output;
}

// Encode the application id as base64.
// Try to use the integer encoding so it'll be as short as possible, but if
// app ID is not a valid 8 byte integer just encode as utf8 string
+ (NSString *)urlSafeBase64ApplicationID {
    NSString *appID = [MaveSDK sharedInstance].appId;

    // check if it's an 8 byte integer by converting to a number then back
    // to string and making sure it's the same number
    int64_t idAsNumber = [appID longLongValue];
    NSString *backToString = [NSString stringWithFormat:@"%lld", idAsNumber];
    BOOL isIDNumber = [backToString isEqualToString:appID];

    NSData *appIDData;
    if (isIDNumber) {
        long long idNetworkEndian = NSSwapHostLongLongToBig(idAsNumber);
        appIDData = [NSData dataWithBytes:&idNetworkEndian
                                   length:sizeof(idNetworkEndian)];
    } else {
        appIDData = [appID dataUsingEncoding:NSUTF8StringEncoding];
    }

    return [self urlSafeBase64EncodeAndStripData:appIDData];
}


@end
