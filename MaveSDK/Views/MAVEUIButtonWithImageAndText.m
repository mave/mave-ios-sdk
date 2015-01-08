//
//  MAVEUIButtonWithImageAndText.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import "MAVEUIButtonWithImageAndText.h"

NSString *const MAVEShareTypeClientSMS = @"MAVEShareTypeClientSMS";
NSString *const MAVEShareTypeClientEmail = @"MAVEShareTypeClientEmail";
NSString *const MAVEShareTypeOSNativeFacebook = @"MAVEShareTypeOSNativeFacebook";
NSString *const MAVEShareTypeOSNativeTwitter = @"MAVEShareTypeOSNativeTwitter";
NSString *const MAVESharetypeClipboardCopy = @"MAVEShareTypeClipboardCopy";

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
