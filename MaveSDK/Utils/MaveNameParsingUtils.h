//
//  MAVENameParsingUtils.h
//  MaveSDK
//
//  Helpers for parsing names, for anonymous users we want to gues
//  user names from the device name.
//  Created by Danny Cosson on 1/12/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEUserData.h"

@interface MAVENameParsingUtils : NSObject

+ (void)fillFirstName:(NSString **)firstName
             lastName:(NSString **)lastName
       fromDeviceName:(NSString *)deviceName;

+ (NSString *)joinFirstName:(NSString *)firstName
                andLastName:(NSString *)lastName;

// checks against bad word list, case insensitive
+ (BOOL)isBadWord:(NSString *)word;

// Google's list of bad words http://fffff.at/googles-official-list-of-bad-words/
+ (NSDictionary *)badWordsList;

@end
