//
//  MAVEIDUtils.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/21/14.
//
//

#import <Foundation/Foundation.h>

@interface MAVEIDUtils : NSObject

+ (NSString *)loadOrCreateNewAppDeviceID;
+ (void)clearStoredAppDeviceID;

+ (NSString *)generateAppDeviceIDUUIDString;

@end
