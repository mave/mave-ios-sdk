//
//  MAVEInviteFriendsReusableOvalButton.h
//  MaveSDK
//
//  Created by Danny Cosson on 6/9/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVEInviteFriendsReusableOvalButton : UIButton

@property (nonatomic, strong) UIColor *textAndIconColor;

@property (nonatomic, strong) UIImage *untintedImage;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *customImageView;
@property (nonatomic, strong) UILabel *customLabel;

- (void)setHeight:(CGFloat)height;

@end
