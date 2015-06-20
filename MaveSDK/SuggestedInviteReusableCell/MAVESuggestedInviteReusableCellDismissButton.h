//
//  MAVESuggestedInviteReusableCellDismissButton.h
//  MaveSDK
//
//  Created by Danny Cosson on 6/7/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVESuggestedInviteReusableCellDismissButton : UIButton

@property (nonatomic, strong) UIColor *iconColor;
@property (nonatomic, strong) UIImage *untintedImage;
@property (nonatomic, strong) UIImageView *customImageView;
@property (nonatomic, strong) void(^dismissBlock)();

@end
