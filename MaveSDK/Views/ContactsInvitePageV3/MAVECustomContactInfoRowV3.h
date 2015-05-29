//
//  MAVECustomContactInfoRowV3.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/22/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEContactIdentifierBase.h"

@interface MAVECustomContactInfoRowV3 : UIView

@property (nonatomic, weak) MAVEContactIdentifierBase *contactIdentifierRecord;
@property (nonatomic, strong) UIFont *labelFont;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *deselectedColor;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *checkmarkView;
@property (nonatomic, strong) UIImage *untintedCheckmark;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isOnlyContactIdentifier;
@property (nonatomic, strong) void (^rowWasTappedBlock)(BOOL isSelected);

- (instancetype)initWithFont:(UIFont *)font selectedColor:(UIColor *)selectedColor deselectedColor:(UIColor *)deselectedColor;
- (void)tappedRow;
+ (CGFloat)heightGivenFont:(UIFont *)font;

- (void)updateWithContactIdentifierRecord:(MAVEContactIdentifierBase *)contactIdentifier isOnlyContactIdentifier:(BOOL)isOnlyContactIdentifier;

@end
