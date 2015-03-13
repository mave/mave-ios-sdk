//
//  MAVEIDUtils.m
//  MaveSDK
//
//  Helper functions for dealing with ID's and persistent IDs
//  Created by Danny Cosson on 11/21/14.
//
//

#import "MAVEIDUtils.h"
#import "MAVEConstants.h"
#import <uuid/uuid.h>

@implementation MAVEIDUtils

+ (NSString *)loadOrCreateNewAppDeviceID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *appDeviceID;
    NSData *data = [userDefaults objectForKey:MAVEUserDefaultsKeyAppDeviceID];
    if (data) {
        appDeviceID = [[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding];
    } else {
        MAVEInfoLog(@"Generating new UUID for this app on this device");
        appDeviceID = [self generateAppDeviceIDUUIDString];
        [userDefaults setObject:[appDeviceID dataUsingEncoding:NSUTF8StringEncoding]
                         forKey:MAVEUserDefaultsKeyAppDeviceID];
    }
    return appDeviceID;
}

+ (void)clearStoredAppDeviceID {
    [[NSUserDefaults standardUserDefaults]
     removeObjectForKey:MAVEUserDefaultsKeyAppDeviceID];
}

+ (NSString *)generateAppDeviceIDUUIDString {
    return [self generateUUIDVersion1String];
}

+ (BOOL)isAppDeviceIDStoredToDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:MAVEUserDefaultsKeyAppDeviceID];
    return (!!data);
}

// Generate uuid1 with timestamp. This is normally MAC address + timestamp, since
// this is an apple provided library presumably it can't use the real MAC address
// in which case it will fall back to 6 random bytes instead
+ (NSString *)generateUUIDVersion1String {
    uuid_t uuidBytes;
    uuid_generate_time((unsigned char*)uuidBytes);
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDBytes:uuidBytes];
    return uuid.UUIDString;
}

// All random bytes, uuid4
//+ (NSString *)generateUUIDVersion4String {
//    return [NSUUID UUID].UUIDString;
//}




@end
