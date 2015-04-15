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

// Tries to return the "MaveSDK" bundle created on pod install, falls back to
// mainBundle which is correct for DemoApp testing or apps that copy source code
// without using cocoapods
+ (NSBundle *)bundleForMave;

// Transparently get images just by name or from a bundle
+ (UIImage *)imageNamed:(NSString *)imageName fromBundle:(NSString *)bundleName;

// Helper to resize an image
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

// Mask a white & transparent image (like an icon) with the given color
+ (UIImage *)tintWhitesInImage:(UIImage *)baseImage withColor:(UIColor *)tintColor;

@end


// Subclass of UIButton that lays out the title label right below the image
@interface MAVEUIButtonWithImageAndText : UIButton

@property (nonatomic) CGFloat paddingBetweenImageAndText;

@end
