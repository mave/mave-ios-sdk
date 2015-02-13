//
//  MAVECompressionUtils.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <zlib.h>
#import "MAVECompressionUtils.h"

@implementation MAVECompressionUtils

+ (NSData *)gzipCompressData:(NSData *)uncompressedData {
    if ([uncompressedData length] > UINT_MAX) {
        // this case is unrealistic but just to prevent any kind of overflow
        return nil;
    }
    uint uncompressedLength = (uint)[uncompressedData length];
    if (uncompressedLength == 0) {
        return uncompressedData;
    }

    z_stream strm;

    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[uncompressedData bytes];
    strm.avail_in = uncompressedLength;

    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION

    // The window bits is what makes it zlib vs gzip, 15 is a standard for zlib and adding 16
    // makes it gzip format
    uint GZIP_WINDOW_BITS = 15 + 16;
    int MEM_LEVEL = 8;  // This is the default
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, GZIP_WINDOW_BITS, MEM_LEVEL, Z_DEFAULT_STRATEGY) != Z_OK) {
        return nil;
    }
    uint CHUNK_LENGTH = 16384;  // We'll start at 16K chunks and expand if more data
    NSMutableData *compressed = [NSMutableData dataWithLength:CHUNK_LENGTH];  // 16K chunks for expansion

    do {

        if (strm.total_out >= [compressed length]) {
            [compressed increaseLengthBy: CHUNK_LENGTH];
        }

        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = ((uint)[compressed length]) - (uint)strm.total_out;

        deflate(&strm, Z_FINISH);

    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}

+ (NSData *)gzipUncompressData:(NSData *)compressedData {
    if ([compressedData length] > UINT_MAX) {
        // this case is unrealistic but just to prevent any kind of overflow
        return nil;
    }
    if ([compressedData length] == 0) {
        return compressedData;
    }

    uint full_length = (uint)[compressedData length];
    uint half_length = (uint)[compressedData length] / 2;

    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;

    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = full_length;
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;

    uint GZIP_WINDOW_BITS = 15 + 16;
    if (inflateInit2(&strm, GZIP_WINDOW_BITS) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = ((uint)[decompressed length]) - ((uint)strm.total_out);

        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
    }
    if (inflateEnd (&strm) != Z_OK) {
        return nil;
    }
    
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
}

@end
