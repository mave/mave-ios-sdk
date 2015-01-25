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

+ (NSString *)md5HashHexStringValue:(NSData *)data {
    if (data.length > UINT_MAX) {
        return nil;
    }
    uint dataLength = (uint)data.length;
    unsigned char md5Chars[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, dataLength, md5Chars);

    NSMutableString *outputMutable = [[NSMutableString alloc]initWithCapacity:sizeof(md5Chars)];
    for (NSUInteger i = 0; i < sizeof(md5Chars); ++i) {
        [outputMutable appendFormat:@"%02x", md5Chars[i]];
    }
    return [NSString stringWithString:outputMutable];
}

@end
