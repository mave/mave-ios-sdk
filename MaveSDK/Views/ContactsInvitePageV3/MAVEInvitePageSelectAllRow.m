//
//  MAVEInvitePageSelectAllRow.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/28/15.
//
//

#import "MAVEInvitePageSelectAllRow.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVEDisplayOptions.h"
#import "MAVEConstants.h"

@implementation MAVEInvitePageSelectAllRow {
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
    self.backgroundColor = [MAVEDisplayOptions colorAppleLightGray];
    self.icon = [[UIImageView alloc] init];
    UIImage *envelope = [MAVEBuiltinUIElementUtils imageNamed:@"MAVEEnvelope.png" fromBundle:MAVEResourceBundleName];
    envelope = [MAVEBuiltinUIElementUtils tintWhitesInImage:envelope withColor:[UIColor grayColor]];
    self.icon.image = envelope;
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [MAVEDisplayOptions invitePageV3BiggerFont];
    self.textLabel.textColor = [MAVEDisplayOptions colorAppleBlack];
    self.checkbox = [[MAVECustomCheckboxV3 alloc] init];
    UITapGestureRecognizer *tapCheckbox = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCheckbox)];
    [self.checkbox addGestureRecognizer:tapCheckbox];

    self.topSeparatorBar = [[UIView alloc] init];
    self.topSeparatorBar.backgroundColor = [MAVEDisplayOptions colorAppleDarkGray];
    self.bottomSeparatorBar = [[UIView alloc] init];
    self.bottomSeparatorBar.backgroundColor = [MAVEDisplayOptions colorAppleDarkGray];

    self.topSeparatorBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.checkbox.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomSeparatorBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.topSeparatorBar];
    [self addSubview:self.icon];
    [self addSubview:self.textLabel];
    [self addSubview:self.checkbox];
    [self addSubview:self.bottomSeparatorBar];

    [self setNeedsUpdateConstraints];
}

- (void)setupInitialConstraints {
    NSDictionary *views = @{@"icon": self.icon,
                            @"textLabel": self.textLabel,
                            @"checkbox": self.checkbox};
    NSDictionary *metrics = @{@"checkboxRightOffset": @(48)};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[icon]-10-[textLabel]-(>=10)-[checkbox]-(checkboxRightOffset)-|" options:0 metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.icon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkbox attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

    // Separator bars
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topSeparatorBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topSeparatorBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topSeparatorBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topSeparatorBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomSeparatorBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomSeparatorBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomSeparatorBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomSeparatorBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];
}

- (CGSize)intrinsicContentSize {
    CGFloat height = [@"Some String Here" sizeWithAttributes:@{NSFontAttributeName: self.textLabel.font}].height;
    height = height + 2 * 12;  // account for extra padding above/below
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

- (void)updateConstraints {
    if (!_didSetupInitialConstraints) {
        [self setupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}

- (void)didTapCheckbox {
    BOOL newCheckboxState = !self.checkbox.isChecked;
    [self.checkbox animateToggleCheckmark];
    if (self.selectAllBlock) {
        self.selectAllBlock(newCheckboxState);
    }
}


@end