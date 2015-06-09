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

    self.backgroundOverlay = [[UIView alloc] init];
    self.backgroundOverlay.backgroundColor = [UIColor redColor];
    self.backgroundOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundOverlay.layer.cornerRadius = 17;
    self.backgroundOverlay.layer.masksToBounds = YES;
    UIImage *overlayImage = [MAVEBuiltinUIElementUtils tintWhitesInImage:self.untintedImage withColor:[UIColor whiteColor]];
    self.overlayImageView = [[UIImageView alloc] initWithImage:overlayImage];
    self.overlayImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.customImageView];
    [self addSubview:self.backgroundOverlay];
    [self.backgroundOverlay addSubview:self.overlayImageView];

    [self tintForNonHighlighted];
    [self addTarget:self action:@selector(tintForHighlighted) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(tintForNonHighlighted) forControlEvents:(UIControlEventTouchUpInside^UIControlEventTouchUpOutside)];
    [self addTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];

    [self setNeedsUpdateConstraints];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateConstraints];
            [self removeConstraint:self.overlayShrunkDiameterConstraint];
            [self addConstraint:self.overlayExpandedDiameterConstraint];
        [UIView animateWithDuration:2.0f animations:^{
            [self layoutIfNeeded];
        }];
    });
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

    // background overlay
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.backgroundOverlay addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.backgroundOverlay attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];

    self.overlayExpandedDiameterConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    self.overlayShrunkDiameterConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
    [self addConstraint:self.overlayShrunkDiameterConstraint];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];

}

- (void)updateConstraints {
    if(!_didSetupInitialConstraints) {
        [self doSetupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layout subviews");
    self.backgroundOverlay.layer.cornerRadius = self.backgroundOverlay.frame.size.height / 2;
}

@end
