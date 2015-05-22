//
//  MAVECustomContactInfoRowV3.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/22/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVECustomContactInfoRowV3 : UIView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *checkmarkView;
@property (nonatomic, strong) UIImage *untintedCheckmark;
@property (nonatomic, assign) BOOL isSelected;

- (void)updateWithLabelText:(NSString *)labelText isSelected:(BOOL)isSelected;
- (CGFloat)heightForCurrentFont;

@end
