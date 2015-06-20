//
//  MAVESuggestedInviteReusableInviteFriendsButtonTableViewCell.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/9/15.
//
//

#import "MAVESuggestedInviteReusableInviteFriendsButtonTableViewCell.h"

@implementation MAVESuggestedInviteReusableInviteFriendsButtonTableViewCell {
    BOOL _didSetupInitialConstraints;
}

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.inviteFriendsButton = [[MAVEInviteFriendsReusableOvalButton alloc] init];
    self.inviteFriendsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.inviteFriendsButton];

    [self setNeedsUpdateConstraints];
}

- (void)setupInitialConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.inviteFriendsButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.inviteFriendsButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10]];
}

- (void)updateConstraints {
    [super updateConstraints];
    if (!_didSetupInitialConstraints) {
        [self setupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
}

@end
