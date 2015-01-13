//
//  MAVEBuiltinUIElementUtils.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import "MAVEBuiltinUIElementUtils.h"

@implementation MAVEBuiltinUIElementUtils

+ (UIImage *)imageNamed:(NSString *)imageName fromBundle:(NSString *)bundleName {
    UIImage *image;
    // Try getting it from the bundle (how it will be fetched live)
    NSURL *bundleURL; NSBundle *bundle;
    bundleURL = [[NSBundle mainBundle] URLForResource:bundleName withExtension:@"bundle"];
    if (bundleURL) {
        bundle = [NSBundle bundleWithURL:bundleURL];
    }
    if (bundle) {
        image = [UIImage imageWithContentsOfFile:[[bundle resourcePath] stringByAppendingPathComponent:imageName]];
    }

    // Otherwise fall back to getting image by name (when running this DemoApp or tests)
    if (!image) {
        image = [UIImage imageNamed:imageName];
    }
    return image;
}

+ (UIImage *)tintWhitesInImage:(UIImage *)baseImage withColor:(UIColor *)tintColor {
    if (!baseImage) {
        return nil;
    }

    CGRect drawRect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);

    UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(context, 0, baseImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // draw original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, drawRect, baseImage.CGImage);

    // draw color atop
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextFillRect(context, drawRect);

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

@end



@implementation MAVEUIButtonWithImageAndText

-(void)layoutSubviews {
    [super layoutSubviews];
    // Move the image to the top and center it horizontally
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.y = 0;
    imageFrame.origin.x = (self.frame.size.width / 2) - (imageFrame.size.width / 2);
    self.imageView.frame = imageFrame;

    // Adjust the label size to fit the text, and move it below the image
    CGRect titleLabelFrame = self.titleLabel.frame;
    CGSize labelSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:self.titleLabel.font}
                                                          context:nil].size;
    titleLabelFrame.size.width = labelSize.width;
    titleLabelFrame.size.height = labelSize.height;
    titleLabelFrame.origin.x = (self.frame.size.width / 2) - (labelSize.width / 2);
    titleLabelFrame.origin.y = self.imageView.frame.origin.y +
    self.imageView.frame.size.height +
    self.paddingBetweenImageAndText;
    self.titleLabel.frame = titleLabelFrame;
}

@end