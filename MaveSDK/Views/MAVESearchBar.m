//
//  MAVESearchBar.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/16/15.
//
//

#import "MAVESearchBar.h"
#import "MaveSDK.h"

CGFloat const MAVESearchBarHeight = 44.0;

@implementation MAVESearchBar

- (instancetype)initWithSingletonSearchBarDisplayOptions {
    if (self = [super init]) {
        [self setupDefaults];
        MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
        self.searchBarFont = displayOptions.searchBarFont;
        self.searchBarPlaceholderTextColor = displayOptions.searchBarPlaceholderTextColor;
        self.searchBarTextColor = displayOptions.searchBarSearchTextColor;
        self.backgroundColor = displayOptions.searchBarBackgroundColor;

        [self setupInit];
    }
    return self;
}

- (instancetype)initWithFont:(UIFont *)font placeholderTextColor:(UIColor *)placeholderTextColor textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
    if (self = [super init]) {
        [self setupDefaults];
        self.searchBarFont = font;
        self.searchBarPlaceholderTextColor = placeholderTextColor;
        self.searchBarTextColor = textColor;
        self.backgroundColor = backgroundColor;

        [self setupInit];
    }
    return self;
}

- (void)setupDefaults {
    self.placeholderText = @"Enter name to search";
    self.placeholderToFieldText = @"To:";
}

- (void)setupInit {
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.font = self.searchBarFont;
    self.textColor = self.searchBarTextColor;
    self.attributedPlaceholder = [[NSAttributedString alloc]
                                  initWithString:self.placeholderText
                                  attributes:@{NSForegroundColorAttributeName: self.searchBarPlaceholderTextColor,
                                               NSFontAttributeName: self.searchBarFont,
                                               }];
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    [self setupLeftLabelView];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, MAVESearchBarHeight);
}

- (void)setupLeftLabelView {
    CGFloat paddingXPre = 14;
    CGFloat paddingXPost = 10;

    UILabel *label = [[UILabel alloc] init];
    label.text = self.placeholderToFieldText;
    label.textColor = self.searchBarPlaceholderTextColor;
    label.font = self.searchBarFont;

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
