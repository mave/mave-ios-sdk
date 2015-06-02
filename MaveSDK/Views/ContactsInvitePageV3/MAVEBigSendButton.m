//
//  MAVEBigSendButton.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import "MAVEBigSendButton.h"
#import "MaveSDK.h"
#import "MAVEDisplayOptions.h"
#import "MAVEConstants.h"
#import "MAVEBuiltinUIElementUtils.h"

@implementation MAVEBigSendButton {
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
    self.backgroundColor = [MaveSDK sharedInstance].displayOptions.invitePageV3TintColor;
    self.contentContainer = [[UIView alloc] init];
    self.contentContainer.userInteractionEnabled = NO;
    self.icon = [[UIImageView alloc] init];
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [MAVEDisplayOptions invitePageV3BiggerFont];
    self.textLabel.textColor = [UIColor whiteColor];
    [self updateButtonTextNumberToSend:0];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidden = YES;

    self.centeredTextLabel = [[UILabel alloc] init];
    self.centeredTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.centeredTextLabel.font = [MAVEDisplayOptions invitePageV3BiggerFont];
    self.centeredTextLabel.textColor = [UIColor whiteColor];
    self.centeredTextLabel.text = @"Sent!";
    self.centeredTextLabel.hidden = YES;

    self.contentContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *airplane = [MAVEBuiltinUIElementUtils imageNamed:@"MAVEAirplane.png" fromBundle:MAVEResourceBundleName];
    self.icon.image = [MAVEBuiltinUIElementUtils tintWhitesInImage:airplane withColor:[UIColor whiteColor]];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentContainer];
    [self.contentContainer addSubview:self.icon];
    [self.contentContainer addSubview:self.textLabel];
    [self.contentContainer addSubview:self.activityIndicator];
    [self.contentContainer addSubview:self.centeredTextLabel];
}

- (void)setupInitialConstriants {
    // center the container
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

    // connect icon and label to container
    // X Constraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.icon attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentContainer attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.icon attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentContainer attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    // Y Constraints
    //     pin label to top and bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentContainer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    //     center icon vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.icon attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

    // Center activity indicator in content container
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    // Center the centered text label in content container
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centeredTextLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.centeredTextLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)updateConstraints {
    if (!_didSetupInitialConstraints) {
        [self setupInitialConstriants];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}

- (void)updateButtonTextNumberToSend:(NSUInteger)numberToSend {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    self.centeredTextLabel.hidden = YES;
    self.textLabel.hidden = NO;
    self.icon.hidden = NO;
    NSString *noun = numberToSend == 1 ? @"Invite" : @"Invites";
    NSString *text = [NSString stringWithFormat:@"Send %@ %@", @(numberToSend), noun];
    self.textLabel.text = text;
}

- (void)updateButtonToSendingStatus {
    self.textLabel.hidden = YES;
    self.icon.hidden = YES;
    self.centeredTextLabel.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)updateButtonToSentStatus {
    self.textLabel.hidden = YES;
    self.icon.hidden = YES;
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    self.centeredTextLabel.hidden = NO;
}

@end
