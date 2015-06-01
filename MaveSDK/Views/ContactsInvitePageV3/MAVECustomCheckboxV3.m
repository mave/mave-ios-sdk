//
//  MAVECustomCheckboxV3.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/22/15.
//
//

#import "MAVECustomCheckboxV3.h"
#import "MAVEDisplayOptions.h"
#import "MAVEConstants.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MaveSDK.h"

@implementation MAVECustomCheckboxV3 {
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

- (void)doInitialSetup {
    self.widthAndHeight = 20;
    self.layer.borderColor = [[MAVEDisplayOptions colorAppleDarkGray] CGColor];
    self.layer.cornerRadius = self.widthAndHeight * 0.25;
    self.isChecked = NO;

    self.tintColor = [MaveSDK sharedInstance].displayOptions.invitePageV3TintColor;
    self.checkmarkImage = [[UIImageView alloc] init];
    UIImage *checkmark = [MAVEBuiltinUIElementUtils imageNamed:@"MAVESimpleCheckmark.png" fromBundle:MAVEResourceBundleName];
    self.checkmarkImage.image = [MAVEBuiltinUIElementUtils tintWhitesInImage:checkmark withColor:[UIColor whiteColor]];
    self.checkmarkImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.checkmarkImage];

    [self setNeedsUpdateConstraints];
}

- (void)setIsChecked:(BOOL)isChecked {
    _isChecked = isChecked;
    if (isChecked) {
        self.backgroundColor = self.tintColor;
        self.layer.borderWidth = 0;
    } else {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1.0f;
    }
}

- (void)animateToggleCheckmark {
    BOOL newIsCheckedState = !self.isChecked;
    if (newIsCheckedState) {
        [self animateCheckCheckmark];
    } else {
        [self animateUncheckCheckmark];
    }
}

- (void)animateCheckCheckmark {
    CGFloat pt1Length = 0.2f;
    CGFloat pt2Length = 0.2f;
    self.isChecked = YES;
    self.checkmarkImageHeightConstraint.constant = [self checkmarkWidthAndHeight] * 1.15;
    [UIView animateWithDuration:pt1Length animations:^{
        [self layoutIfNeeded];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pt1Length * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.checkmarkImageHeightConstraint.constant = [self checkmarkWidthAndHeight];
        [UIView animateWithDuration:pt2Length animations:^{
            [self layoutIfNeeded];
        }];
    });
}

- (void)animateUncheckCheckmark {
    CGFloat pt1Length = 0.2f;
    self.checkmarkImageHeightConstraint.constant = [self checkmarkWidthAndHeight] * 0.75;
    [UIView animateWithDuration:pt1Length * 2 animations:^{
        [self layoutIfNeeded];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pt1Length * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.checkmarkImageHeightConstraint.constant = 0;
        self.isChecked = NO;
        [self layoutIfNeeded];
    });
}

- (CGFloat)checkmarkWidthAndHeight {
    return self.widthAndHeight * 0.75f;
}

- (void)setupInitialConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkmarkImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkmarkImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkmarkImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.checkmarkImage attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    CGFloat currentCheckmarkHeight = self.isChecked ? [self checkmarkWidthAndHeight] : 0;
    self.checkmarkImageHeightConstraint = [NSLayoutConstraint constraintWithItem:self.checkmarkImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:currentCheckmarkHeight];
    [self addConstraint:self.checkmarkImageHeightConstraint];
}

- (void)updateConstraints {
    if (!_didSetupInitialConstraints) {
        [self setupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.widthAndHeight, self.widthAndHeight);
}

@end
