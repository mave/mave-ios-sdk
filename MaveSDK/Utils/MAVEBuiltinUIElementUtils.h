//
//  MAVEBuiltinUIElementUtils.h
//  MaveSDK
//
//  Some helper utilities for small tweaks to standard builtin UI components
//  like buttons and images.
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <UIKit/UIKit.h>


@interface MAVEBuiltinUIElementUtils : NSObject

// Transparently get images just by name or from a bundle
+ (UIImage *)imageNamed:(NSString *)imageName fromBundle:(NSString *)bundleName;

// Mask a white & transparent image (like an icon) with the given color
+ (UIImage *)tintWhitesInImage:(UIImage *)baseImage withColor:(UIColor *)tintColor;

@end


// Subclass of UIButton that lays out the title label right below the image
@interface MAVEUIButtonWithImageAndText : UIButton

@property (nonatomic) CGFloat paddingBetweenImageAndText;

@end