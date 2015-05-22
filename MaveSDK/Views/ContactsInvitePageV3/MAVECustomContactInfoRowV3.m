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

- (void)updateWithLabelText:(NSString *)labelText isSelected:(BOOL)isSelected {
    self.label.text = labelText;
    self.isSelected = isSelected;
}

- (void)doInitialSetup {
    self.label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.font = [UIFont systemFontOfSize:14];
    self.label.textColor = [UIColor grayColor];
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
    CGFloat labelHeight = [self heightForCurrentFont];
    NSDictionary *metrics = @{@"labelHeight": @(labelHeight),
                              @"checkmarkHeight": @(labelHeight * 0.75)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-2-[checkmarkView(==checkmarkHeight)]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label(==labelHeight)]-0-|" options:0 metrics:metrics views:views]];
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

- (CGFloat)heightForCurrentFont {
    return [@"(123) 555-4567" sizeWithAttributes:@{NSFontAttributeName: self.label.font}].height;
}

@end
