//
//  MAVEHashingUtils.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVEHashingUtils : NSObject

+ (NSString *)hexStringFromData:(NSData *)data;
+ (NSData *)dataFromHexString:(NSString *)string;

+ (NSData *)md5Hash:(NSData *)data;

// Returns an unsigned int using the first 4 bytes of the md5 hash
// of an integer, for the purpose of converting the number into
// one we know is uniformly distributed.
//
// Uses big endian byte order
+ (NSUInteger)randomizeInt32WithMD5hash:(int32_t)number;

@end