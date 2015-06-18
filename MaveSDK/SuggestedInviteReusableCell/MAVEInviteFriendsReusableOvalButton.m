//
//  MAVEInviteFriendsReusableOvalButton.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/9/15.
//
//

#import "MAVEInviteFriendsReusableOvalButton.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVEConstants.h"
#import "MAVEDisplayOptions.h"
#import "MaveSDK.h"

@implementation MAVEInviteFriendsReusableOvalButton {
    BOOL _didSetupConstraints;
    NSLayoutConstraint *_heightConstraint;
    UIColor *_unselectedBackgroundColor;
}

- (instancetype)init {
    self = [[self class] buttonWithType:UIButtonTypeSystem];
    if (self) {
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
    self.inviteContext = @"MAVEInviteFriendsReusableOvalButton";

    self.customBackgroundColor = [UIColor colorWithRed:112.0/255.0 green:192.0/255.0 blue:215.0/255.0 alpha:1.0];

    self.containerView = [[UIView alloc] init];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.userInteractionEnabled = NO;
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
    self.customLabel = [[UILabel alloc] init];
    self.customLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.customLabel.font = [UIFont systemFontOfSize:20];
    self.customLabel.text = @"Invite friends";
    self.customImageView = [[UIImageView alloc] init];
    self.customImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.untintedImage = [MAVEBuiltinUIElementUtils imageNamed:@"MAVEInviteIcon.png" fromBundle:MAVEResourceBundleName];

    [self addSubview:self.containerView];
    [self.containerView addSubview:self.customImageView];
    [self.containerView addSubview:self.customLabel];

    [self setHeight:50];
    [self setTextAndIconColor:[UIColor whiteColor]];

    [self addTarget:self action:@selector(grayButtonWhenPressed) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(unGrayButtonWhenReleased) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(presentInvitePageModally) forControlEvents:UIControlEventTouchUpInside];

    [self setNeedsUpdateConstraints];
}

- (void)grayButtonWhenPressed {
    self.backgroundColor = [MAVEDisplayOptions colorAppleMediumGray];
}

- (void)unGrayButtonWhenReleased {
    self.backgroundColor = self.customBackgroundColor;
}

- (void)presentInvitePageModally {
    UIViewController *controllingVC = [self controllingViewController];
    if (!controllingVC) {
        MAVEErrorLog(@"Couldnt find a parent vc to present invite page when pressed InviteFriendsReusableOvalButton");
        return;
    }
    [[MaveSDK sharedInstance] presentInvitePageModallyWithBlock:^(UIViewController *inviteController) {
        [controllingVC presentViewController:inviteController animated:YES completion:nil];
    } dismissBlock:^(UIViewController *controller, NSUInteger numberOfInvitesSent) {
        if (self.openedInvitePageBlock) {
            self.openedInvitePageBlock(numberOfInvitesSent);
        }
        [controller dismissViewControllerAnimated:YES completion:nil];
    } inviteContext:self.inviteContext];
}

- (UIViewController *)controllingViewController {
    UIResponder *responder = self;
    while (responder && [responder isKindOfClass:[UIView class]]) {
        responder = [responder nextResponder];
    }
    if (!responder) {
        return nil;
    }
    return  (UIViewController *)responder;
}

- (void)setTextAndIconColor:(UIColor *)textAndIconColor {
    self.customLabel.textColor = textAndIconColor;
    self.customImageView.image = [MAVEBuiltinUIElementUtils tintWhitesInImage:self.untintedImage withColor:textAndIconColor];
}

- (void)setHeight:(CGFloat)height {
    _heightConstraint.constant = height;
    self.layer.cornerRadius = height / 2;
}

- (void)setCustomBackgroundColor:(UIColor *)customBackgroundColor {
    _customBackgroundColor = customBackgroundColor;
    self.backgroundColor = customBackgroundColor;
}

- (void)setupInitialConstraints {
    NSDictionary *views = @{@"containerView": self.containerView,
                            @"imageView": self.customImageView,
                            @"label": self.customLabel};
    NSDictionary *metrics = @{@"horizontalOutsidePadding": @(25),
                              @"imageToLabelPadding": @(12)};
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalOutsidePadding)-[containerView]-(horizontalOutsidePadding)-|" options:0 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-(imageToLabelPadding)-[label]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[imageView]-(>=0)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[label]-(>=0)-|" options:0 metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.customImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.customLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self addConstraint:_heightConstraint];
}

- (void)updateConstraints {
    [super updateConstraints];
    if (!_didSetupConstraints) {
        _didSetupConstraints = YES;
        [self setupInitialConstraints];
    }
}

@end
