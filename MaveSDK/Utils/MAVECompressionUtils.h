//
//  MAVECompressionUtils.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/23/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVECompressionUtils : NSObject

+ (NSData *)gzipCompressData:(NSData *)uncompressedData;
+ (NSData *)gzipUncompressData:(NSData *)compressedData;

@end
