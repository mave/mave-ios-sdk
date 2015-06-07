//
//  MAVESuggestedInviteReusableCellInviteButton.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/7/15.
//
//

#import "MAVESuggestedInviteReusableCellInviteButton.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVEConstants.h"
#import "MAVEDisplayOptions.h"

@implementation MAVESuggestedInviteReusableCellInviteButton {
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
    self.layer.borderWidth = 2.0f;
    self.iconColor = [UIColor colorWithRed:112.0/255.0 green:192.0/255.0 blue:215.0/255.0 alpha:1.0];
    self.untintedImage = [MAVEBuiltinUIElementUtils imageNamed:@"MAVEInviteIconSmall.png" fromBundle:MAVEResourceBundleName];
    self.customImageView = [[UIImageView alloc] initWithImage:self.untintedImage];

    self.customImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.customImageView];

    [self tintForNonHighlighted];
    [self addTarget:self action:@selector(tintForHighlighted) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(tintForNonHighlighted) forControlEvents:(UIControlEventTouchUpInside^UIControlEventTouchUpOutside)];
    [self addTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];

    [self setNeedsUpdateConstraints];
}

- (void)tintForHighlighted {
    UIColor *borderTinted = [MAVEDisplayOptions colorAppleLightGray];
    UIColor *iconTinted = [MAVEDisplayOptions colorAppleMediumLightGray];
    self.customImageView.image = [MAVEBuiltinUIElementUtils tintWhitesInImage:self.untintedImage withColor:iconTinted];
    self.layer.borderColor = [borderTinted CGColor];
}

- (void)tintForNonHighlighted {
    UIColor *borderColor = [MAVEDisplayOptions colorAppleMediumLightGray];
    self.customImageView.image = [MAVEBuiltinUIElementUtils tintWhitesInImage:self.untintedImage withColor:self.iconColor];
    self.layer.borderColor = [borderColor CGColor];
}

- (void)doAction {
    if (self.sendInviteBlock) {
        self.sendInviteBlock();
    }
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
