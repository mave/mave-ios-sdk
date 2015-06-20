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
#import "MaveSDK.h"

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
    UIColor *borderColor = [MAVEDisplayOptions colorAppleMediumLightGray];
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [borderColor CGColor];

    NSString *imageName = [MaveSDK sharedInstance].remoteConfiguration.contactsInvitePage.reusableSuggestedInviteCellSendIcon == MAVEReusableSuggestedInviteCellSendIconPersonPlus ? @"MAVEInviteIconSmall.png" : @"MAVEAirplaneSmall.png";
    self.untintedImage = [MAVEBuiltinUIElementUtils imageNamed:imageName fromBundle:MAVEResourceBundleName];
    self.customImageView = [[UIImageView alloc] initWithImage:self.untintedImage];
    self.customImageView.translatesAutoresizingMaskIntoConstraints = NO;

    self.backgroundOverlay = [[UIView alloc] init];
    self.backgroundOverlay.userInteractionEnabled = NO;
    self.backgroundOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundOverlay.layer.masksToBounds = YES;
    self.backgroundOverlay.hidden = YES;

    [self addSubview:self.backgroundOverlay];
    [self addSubview:self.customImageView];

    self.iconColor = [MAVEDisplayOptions colorAppleBlueTint];

    [self addTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];

    [self setNeedsUpdateConstraints];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    });
}

- (void)setIconColor:(UIColor *)iconColor {
    _iconColor = iconColor;
    self.backgroundOverlay.backgroundColor = iconColor;
    self.customImageView.image = [MAVEBuiltinUIElementUtils tintWhitesInImage:self.untintedImage withColor:self.iconColor];
}

- (void)doAction {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateClickedButton];
    });
    if (self.sendInviteBlock) {
        self.sendInviteBlock();
    }
}

- (void)animateClickedButton {
    [self updateConstraints];
    self.backgroundOverlay.hidden = NO;
    self.layer.borderWidth = 0;
    self.customImageView.image = [MAVEBuiltinUIElementUtils tintWhitesInImage:self.untintedImage withColor:[UIColor whiteColor]];
    self.backgroundOverlay.layer.cornerRadius = self.frame.size.height / 2;
    [UIView animateWithDuration:0.5f animations:^{
        [self.backgroundOverlay setTransform:CGAffineTransformMakeScale(1, 1)];
    }];
}

- (void)resetButtonNotClicked {
    self.backgroundOverlay.hidden = YES;
    self.layer.borderWidth = 2.0f;
    [self.backgroundOverlay setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
    [self setIconColor:self.iconColor];
}

- (void)doSetupInitialConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.customImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.customImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

    // background overlay
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.backgroundOverlay addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.backgroundOverlay attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.backgroundOverlay setTransform:CGAffineTransformMakeScale(0.1, 0.1)];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundOverlay attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];

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
}

@end
