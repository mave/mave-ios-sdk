//
//  MAVESearchBar.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/16/15.
//
//

#import "MAVESearchBar.h"

CGFloat const MAVESearchBarHeight = 44.0;

@implementation MAVESearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupInit];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupInit];
    }
    return self;
}

- (void)setupInit {
    self.backgroundColor = [UIColor whiteColor];
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.font = [self placeholderFont];
    self.attributedPlaceholder = [[NSAttributedString alloc]
                                  initWithString:@"Enter name or phone number"
                                  attributes:@{NSForegroundColorAttributeName: [self placeholderTextColor],
                                               NSFontAttributeName: [self placeholderFont],
                                               }];
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    [self setupLeftLabelView];
}

// UI colors & sizes to use, will be displayOptions later
- (UIColor *)placeholderTextColor {
    return [UIColor grayColor];
}

- (UIFont *)placeholderFont {
    return [UIFont systemFontOfSize:16];
}

- (void)setupLeftLabelView {
    CGFloat paddingXPre = 8;
    CGFloat paddingXPost = 10;

    UILabel *label = [[UILabel alloc] init];
    label.text = @"To:";
    label.textColor = [self placeholderTextColor];
    label.font = [self placeholderFont];

    CGSize textSize = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    textSize.width = ceil(textSize.width);
    textSize.height = ceil(textSize.height);


    UIView *leftView = [[UIView alloc] init];
    [leftView addSubview:label];

    label.frame = CGRectMake(paddingXPre, 0, textSize.width, textSize.height);
    leftView.frame = CGRectMake(0,
                                0,
                                paddingXPre + textSize.width + paddingXPost,
                                textSize.height);

    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = leftView;
}

@end
