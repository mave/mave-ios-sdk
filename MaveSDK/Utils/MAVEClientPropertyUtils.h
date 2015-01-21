//
//  MAVEClientPropertyUtils.h
//  MaveSDK
//
//  Created by Danny Cosson on 12/30/14.
//
//

#import <Foundation/Foundation.h>

@interface MAVEClientPropertyUtils : NSObject

///
/// Device
///

// This is the ID auto-generated and stored once per device by mave for identification
+ (NSString *)appDeviceID;
// The host application's name, release & version numbers
+ (NSString *)appName;
+ (NSString *)appRelease;
+ (NSString *)appVersion;
// cell carrier the device is registered with (if any, e.g. iPad may not have)
+ (NSString *)carrier;
// current country code set in user's settings
+ (NSString *)countryCode;
// the device's name (e.g. Danny's iPad)
+ (NSString *)deviceName;
+ (NSString *)deviceUsersFullName;
+ (NSString *)deviceUsersFirstName;
+ (NSString *)deviceUsersLastName;
// current language set in user's settings
+ (NSString *)language;
// Mave Version, current version of the mave sdk
+ (NSString *)maveVersion;
// Device manufacturer (Apple)
+ (NSString *)manufacturer;
+ (NSString *)model;
// Operating System info
+ (NSString *)os;
+ (NSString *)osVersion;

// Returns the device part of the user agent string, which has all the info
// available for matching current device against mobile Safari's user agent
// string
+ (NSString *)userAgentDeviceString;

// Returns screen size of  device in the format "AxB"
+ (NSString *)formattedScreenSize;

// This is the dictionary of client properties to include in the event header
// sent with all events to be able to segment later by any available properties.
// Encoded in json base64 string.
+ (NSString *)encodedAutomaticClientProperties;

///
/// Context Properties
///
+ (NSString *)encodedContextProperties;

///
/// Helpers
///
+ (NSString *)base64EncodeDictionary:(NSDictionary *)dict;
+ (NSDictionary *)base64DecodeJSONString:(NSString *)encodedString;

// Base 64 encode, but replace + and / with - and _ so they can be URL values,
// and strip padding = chars since they can be added back (the string length of
// base64 just needs to be a multiple of 4 to make sense).
+ (NSString *)urlSafeBase64EncodeAndStripData:(NSData *)value;
+ (NSString *)urlSafeBase64ApplicationID;

@end