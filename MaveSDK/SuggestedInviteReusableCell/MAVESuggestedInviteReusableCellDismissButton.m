//
//  MAVESuggestedInviteReusableCellDismissButton.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/7/15.
//
//

#import "MAVESuggestedInviteReusableCellDismissButton.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVEConstants.h"
#import "MAVEDisplayOptions.h"

@implementation MAVESuggestedInviteReusableCellDismissButton {
    BOOL _didSetupInitialConstraints;
}

- (instancetype)init {
    self = [[self class] buttonWithType:UIButtonTypeSystem];
    if (self) {
        [self doInitialSetup];
    }
    return  self;
}

- (void)doInitialSetup {
    self.layer.borderColor = [[MAVEDisplayOptions colorAppleMediumLightGray] CGColor];
    self.layer.borderWidth = 2.0f;
    UIImage *image = [MAVEBuiltinUIElementUtils imageNamed:@"MAVECancelX.png" fromBundle:MAVEResourceBundleName];
    self.customImageView = [[UIImageView alloc] initWithImage:image];
    [self setCustomTintColor:[UIColor colorWithRed:167.0/255.0 green:168.0/255.0 blue:171.0/255.0 alpha:1.0]];

    self.customImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.customImageView];

    [self setNeedsUpdateConstraints];
}

- (void)setCustomTintColor:(UIColor *)customTintColor {
    _customTintColor = customTintColor;
    self.customImageView.image = [MAVEBuiltinUIElementUtils tintWhitesInImage:self.customImageView.image withColor:customTintColor];
}

- (void)doSetupInitialConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.customImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.customImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)updateConstraints {
    if(!_didSetupInitialConstraints) {
        [self doSetupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}
@end
