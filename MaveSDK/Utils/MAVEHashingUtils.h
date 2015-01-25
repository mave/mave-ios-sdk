//
//  MAVEHashingUtils.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVEHashingUtils : NSObject

+ (NSString *)md5HashHexStringValue:(NSData *)data;

@end
