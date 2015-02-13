//
//  MAVEMerkleTreeHashUtils.h
//  MaveSDK
//
//  Created by Danny Cosson on 2/9/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVEMerkleTreeHashUtils : NSObject

// Convert data to/from hex string representation
+ (NSString *)hexStringFromData:(NSData *)data;
+ (NSData *)dataFromHexString:(NSString *)string;

// Converts data to/from numerical representations, big endian
+ (uint64_t)UInt64FromData:(NSData *)data;
+ (NSData *)dataFromUInt64:(uint64_t)number;
+ (NSData *)dataFromInt32:(int32_t)number;

// Compute the md5 hash of a block of data
+ (NSData *)md5Hash:(NSData *)data;
+ (NSData *)md5Hash:(NSData *)data truncatedToBytes:(NSUInteger)numBytes;

@end
