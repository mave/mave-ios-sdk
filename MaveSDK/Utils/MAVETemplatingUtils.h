//
//  MAVETemplatingUtils.h
//  MaveSDK
//
//  Created by Danny Cosson on 3/24/15.
//
//

#import <Foundation/Foundation.h>
#import "MAVEUserData.h"

@interface MAVETemplatingUtils : NSObject

// Helper method to interpolate the template string using the current context.
// Available fields in template are user.* and customData.*
+ (NSString *)interpolateTemplateString:(NSString *)templateString
                               withUser:(MAVEUserData *)user
                             customData:(NSDictionary *)customData;

+ (NSString *)interpolateWithSingletonDataTemplateString:(NSString *)templateString;

@end
