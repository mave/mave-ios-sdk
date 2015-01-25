//
//  MAVEHashingUtils.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/25/15.
//
//

#import <Foundation/Foundation.h>

@interface MAVEHashingUtils : NSObject

+ (NSString *)hexStringValue:(NSData *)data;

+ (NSData *)md5Hash:(NSData *)data;

@end
