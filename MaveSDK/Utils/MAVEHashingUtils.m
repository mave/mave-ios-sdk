//
//  MAVEHashingUtils.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import "MAVEHashingUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MAVEHashingUtils

+ (NSString *)hexStringValue:(NSData *)data {
    if (!data) {
        return nil;
    }

    const unsigned char *dataBuffer = (const unsigned char *)data.bytes;
    NSUInteger dataLength = data.length;

    NSMutableString *outputMutable = [[NSMutableString alloc]initWithCapacity:dataLength];
    for (NSUInteger i = 0; i < dataLength; ++i) {
        [outputMutable appendFormat:@"%02x", dataBuffer[i]];
    }
    return [NSString stringWithString:outputMutable];
}

+ (NSData *)md5Hash:(NSData *)data {
    if (data.length > UINT_MAX) {
        return nil;
    }
    uint dataLength = (uint)data.length;
    unsigned char md5Chars[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, dataLength, md5Chars);
    return [NSData dataWithBytes:md5Chars length:sizeof(md5Chars)];
}

+ (NSUInteger)randomizeInt32WithMD5hash:(int32_t)number {
    number = CFSwapInt32HostToBig(number);
    NSData *data = [NSData dataWithBytes:&number
                                  length:sizeof(number)];
    NSData *hashedData = [self md5Hash:data];
    return CFSwapInt64BigToHost(*(NSInteger*)([hashedData bytes]));
}

@end
