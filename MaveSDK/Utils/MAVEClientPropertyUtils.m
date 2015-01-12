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

+ (NSString *)deviceNameParsed {
    NSString *firstName, *lastName;
    [MAVENameParsingUtils fillFirstName:&firstName
                               lastName:&lastName
                         fromDeviceName:[self deviceName]];
    return [MAVENameParsingUtils joinFirstName:firstName andLastName:lastName];
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
    [properties setValue:[self deviceNameParsed] forKey:@"device_name_parsed"];
    [properties setValue:[self maveVersion] forKey: @"mave_version"];
    [properties setValue:[self manufacturer] forKey: @"manufacturer"];
    [properties setValue:[self model] forKey: @"model"];
    [properties setValue:[self os] forKey: @"os"];
    [properties setValue:[self osVersion] forKey: @"osVersion"];

    return [self base64EncodeDictionary:properties];
}

+ (NSString *)base64EncodeDictionary:(NSDictionary *)dict {
    // Base64 encode the dictionary
    NSError *serializationError;
    NSData *jsonString = [NSJSONSerialization dataWithJSONObject:dict
                                                         options:0
                                                           error:&serializationError];
    if (serializationError) {
        DebugLog(@"Error serializing json in base64 helper: %@: %@", serializationError, dict);
        jsonString = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [jsonString base64EncodedStringWithOptions:0];
}

+ (NSDictionary *)base64DecodeJSONString:(NSString *)base64String {
    NSData *jsonData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSError *serializationError;
    NSDictionary *output = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serializationError];
    if (serializationError) {
        DebugLog(@"ERROR deserializing json in base64 helper: %@: %@", serializationError, jsonData);
        output = @{};
    }
    return output;
}


@end