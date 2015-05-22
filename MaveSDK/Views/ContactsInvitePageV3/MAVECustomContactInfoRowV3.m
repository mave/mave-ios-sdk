//
//  MAVECustomContactInfoRowV3.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/22/15.
//
//

#import "MAVECustomContactInfoRowV3.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVEConstants.h"

CGFloat const verticalPadding = 4;

@implementation MAVECustomContactInfoRowV3 {
    BOOL _didSetupInitialConstraints;
}

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self doInitialSetup];
    }
    return self;
}

- (instancetype)initWithFont:(UIFont *)font selectedColor:(UIColor *)selectedColor deselectedColor:(UIColor *)deselectedColor {
    if (self = [super init]) {
        self.labelFont = font;
        self.selectedColor = selectedColor;
        self.deselectedColor = deselectedColor;
        [self doInitialSetup];
    }
    return self;
}

- (void)updateWithLabelText:(NSString *)labelText isSelected:(BOOL)isSelected {
    self.label.text = labelText;
    self.isSelected = isSelected;
}

- (void)doInitialSetup {
    self.label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.font = self.labelFont;
    self.label.textColor = self.deselectedColor;
    [self addSubview:self.label];

    self.checkmarkView = [[UIImageView alloc] init];
    self.checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
    self.untintedCheckmark = [MAVEBuiltinUIElementUtils imageNamed:@"MAVESimpleCheckmark.png" fromBundle:MAVEResourceBundleName];
    self.checkmarkView.image = [MAVEBuiltinUIElementUtils tintWhitesInImage:self.untintedCheckmark withColor:[UIColor grayColor]];
    [self addSubview:self.checkmarkView];

    [self setNeedsUpdateConstraints];
}

- (void)setupInitialConstraints {
    NSDictionary *views = @{@"label": self.label, @"checkmarkView": self.checkmarkView};
    CGFloat labelHeight = [[self class] labelHeightGivenFont:self.label.font];
    NSDictionary *metrics = @{@"labelHeight": @(labelHeight),
                              @"checkmarkHeight": @(labelHeight * 0.6),
                              @"verticalPadding": @(verticalPadding)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-4-[checkmarkView(==checkmarkHeight)]-4-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalPadding-[label(==labelHeight)]-verticalPadding-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[checkmarkView(==checkmarkHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkmarkView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)updateConstraints {
    if (!_didSetupInitialConstraints) {
        [self setupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}

+ (CGFloat)labelHeightGivenFont:(UIFont *)font {
    return [@"(123) 555-4567" sizeWithAttributes:@{NSFontAttributeName: font}].height;
}

+ (CGFloat)heightGivenFont:(UIFont *)font {
    return 2 * verticalPadding + [self labelHeightGivenFont:font];
}

@end
