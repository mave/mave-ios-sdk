//
//  MAVEDisplayOptionsFactory.h
//  MaveSDK
//
//  Created by dannycosson on 10/19/14.
//
//

#import <Foundation/Foundation.h>
#import "MAVEDisplayOptions.h"

@interface MAVEDisplayOptionsFactory : NSObject

+ (MAVEDisplayOptions *)generateDisplayOptions;

+ (UIColor *)randomColor;
+ (UIFont *)randomFont;

@end
