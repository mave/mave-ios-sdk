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

#define MAVEUserDefaultsKeyAppDeviceID @"MAVEUserDefaultsKeyAppDeviceID"

@implementation MAVEIDUtils

+ (NSString *)loadOrCreateNewAppDeviceID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *appDeviceID;
    NSData *data = [userDefaults objectForKey:MAVEUserDefaultsKeyAppDeviceID];
    if (data) {
        appDeviceID = [[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding];
    } else {
        DebugLog(@"Generating new UUID for this app on this device");
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
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    NSString *stringUUID = (__bridge NSString *) CFUUIDCreateString(NULL, theUUID);
    if (theUUID != NULL) CFRelease(theUUID);
    return stringUUID;
}

@end
