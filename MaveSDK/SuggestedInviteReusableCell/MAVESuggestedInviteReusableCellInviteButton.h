//
//  MAVESuggestedInviteReusableCellInviteButton.h
//  MaveSDK
//
//  Created by Danny Cosson on 6/7/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVESuggestedInviteReusableCellInviteButton : UIButton

@property (nonatomic, strong) UIColor *iconColor;
@property (nonatomic, strong) UIImage *untintedImage;
@property (nonatomic, strong) UIView *backgroundOverlay;
@property (nonatomic, strong) UIImageView *customImageView;
@property (nonatomic, strong) void(^sendInviteBlock)();

- (void)resetButtonNotClicked;

@end
