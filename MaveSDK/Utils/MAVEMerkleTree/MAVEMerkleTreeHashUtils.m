//
//  MAVEMerkleTreeHashUtils.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/9/15.
//
//

#import "MAVEMerkleTreeHashUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MAVEMerkleTreeHashUtils

+ (NSString *)hexStringFromData:(NSData *)data {
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

+ (NSData *)dataFromHexString:(NSString *)string {
    if (!string) {
        return nil;
    }
    NSInteger stringLength = [string length];
    NSMutableData *output = [[NSMutableData alloc]initWithCapacity:stringLength/2];

    long byte;
    const char *byteAsString;
    for (NSInteger i = 0; i < stringLength; i+=2) {
        byteAsString = [[string substringWithRange:NSMakeRange(i, 2)]
                        cStringUsingEncoding:NSASCIIStringEncoding];
        byte = strtol(byteAsString, NULL, 16);
        byte = CFSwapInt64HostToLittle(byte);
        [output appendBytes:&byte length:1];
    }
    return [[NSData alloc] initWithData:output];
}

+ (uint64_t)UInt64FromData:(NSData *)data {
    NSData *data8Byte;
    //uint64 is bytes
    if ([data length] < 8) {
        uint64_t zero = 0;
        NSMutableData *tmp = [[NSMutableData alloc] initWithBytes:&zero length:8];
        NSRange replaceRange = NSMakeRange(8-[data length], [data length]);
        [tmp replaceBytesInRange:replaceRange withBytes:[data bytes]];
        data8Byte = [tmp copy];
    } else if ([data length] == 8) {
        data8Byte = data;
    } else {
        data8Byte = [data subdataWithRange:NSMakeRange(0, 8)];
    }
    return CFSwapInt64HostToBig(*(uint64_t *)[data8Byte bytes]);
}

+ (NSData *)dataFromUInt64:(uint64_t)number {
    int64_t swappedNumber = CFSwapInt64HostToBig(number);
    return [NSData dataWithBytes:&swappedNumber length:8];
}

+ (NSData *)dataFromInt32:(int32_t)number {
    int32_t swappedNumber = CFSwapInt32HostToBig(number);
    return [NSData dataWithBytes:&swappedNumber length:4];
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

+ (NSData *)md5Hash:(NSData *)data truncatedToBytes:(NSUInteger)numBytes {
    NSData *hashedData = [self md5Hash:data];
    return [hashedData subdataWithRange:NSMakeRange(0, numBytes)];
}

@end
