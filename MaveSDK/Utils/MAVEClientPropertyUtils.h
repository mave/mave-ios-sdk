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
// The host application's release & version numbers
+ (NSString *)appRelease;
+ (NSString *)appVersion;
// cell carrier the device is registered with (if any, e.g. iPad may not have)
+ (NSString *)carrier;
// current country code set in user's settings
+ (NSString *)countryCode;
// current language set in user's settings
+ (NSString *)language;
// Device manufacturer (Apple)
+ (NSString *)manufacturer;
+ (NSString *)model;
// Operating System info
+ (NSString *)os;
+ (NSString *)osVersion;


// This is the dictionary of client properties to include in the event header
// sent with all events to be able to segment later by any available properties.
// Encoded in json base64 string.
+ (NSString *)encodedAutomaticClientProperties;

// Helpers
+ (NSString *)base64EncodeDictionary:(NSDictionary *)dict;
+ (NSDictionary *)base64DecodeJSONString:(NSString *)encodedString;

@end