//
//  MAVECustomCheckboxV3.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/22/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVECustomCheckboxV3 : UIView

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) CGFloat widthAndHeight;
@property (nonatomic, strong) NSLayoutConstraint *checkmarkImageHeightConstraint;
@property (nonatomic, strong) UIImageView *checkmarkImage;

@property (nonatomic, assign) BOOL isChecked;

- (void)animateToggleCheckmark;

@end
