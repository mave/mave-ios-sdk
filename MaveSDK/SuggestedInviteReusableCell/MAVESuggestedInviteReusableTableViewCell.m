//
//  MAVESuggestedInviteSingleTableViewCell.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/5/15.
//
//

#import "MAVESuggestedInviteReusableTableViewCell.h"
#import "MAVEDisplayOptions.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVEConstants.h"

@implementation MAVESuggestedInviteReusableTableViewCell {
    BOOL _setupInitialConstraints;
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
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    self.pictureViewWidthHeight = 60;
    self.buttonWidthHeight = 34;
    self.betweenButtonPadding = 20;
    self.hLeftPadding = 8;
    self.hRightPadding = 20;
    self.vPicturePadding = 4;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.pictureView = [[UIImageView alloc] init];
    self.pictureView.backgroundColor = [UIColor orangeColor];
    self.pictureView.layer.cornerRadius = self.pictureViewWidthHeight / 2;
    self.pictureView.layer.masksToBounds = YES;
    self.initialsInsteadOfPictureView = [[MAVEInitialsPictureAlternative alloc] init];
    self.initialsInsteadOfPictureView.label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    self.initialsInsteadOfPictureView.layer.cornerRadius = floor(self.pictureViewWidthHeight / 2);
    self.initialsInsteadOfPictureView.layer.masksToBounds = YES;
    self.initialsInsteadOfPictureView.hidden = YES;
    self.textContainer = [[UIView alloc] init];
    self.nameLabel = [[UILabel alloc] init];
    self.subtitleLabel = [[UILabel alloc] init];
    self.dismissButton = [[MAVESuggestedInviteReusableCellDismissButton alloc] init];
    self.dismissButton.layer.cornerRadius = self.buttonWidthHeight / 2;
    self.dismissButton.layer.masksToBounds = YES;
    self.inviteButton = [[MAVESuggestedInviteReusableCellInviteButton alloc] init];
    self.inviteButton.layer.cornerRadius = self.buttonWidthHeight / 2;
    self.inviteButton.layer.masksToBounds = YES;

    self.bottomSeparator = [[UIView alloc] init];
    self.bottomSeparator.backgroundColor = [MAVEDisplayOptions colorAppleMediumGray];

    self.pictureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.initialsInsteadOfPictureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.inviteButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.pictureView];
    [self.contentView addSubview:self.initialsInsteadOfPictureView];
    [self.contentView addSubview:self.textContainer];
    [self.textContainer addSubview:self.nameLabel];
    [self.textContainer addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.dismissButton];
    [self.contentView addSubview:self.inviteButton];
    [self.contentView addSubview:self.bottomSeparator];

    self.highlightColor = [UIColor colorWithRed:112.0/255.0 green:192.0/255.0 blue:215.0/255.0 alpha:1.0];

    [self setNeedsUpdateConstraints];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    self.inviteButton.iconColor = self.highlightColor;
}

- (void)setupInitialConstraints {
    NSDictionary *views = @{@"pictureView": self.pictureView,
                            @"initialsInsteadOfPictureView": self.initialsInsteadOfPictureView,
                            @"textContainer": self.textContainer,
                            @"nameLabel": self.nameLabel,
                            @"subtitleLabel": self.subtitleLabel,
                            @"dismissButton": self.dismissButton,
                            @"sendButton": self.inviteButton,
                            @"bottomSeparator": self.bottomSeparator};
    NSDictionary *metrics = @{@"pictureViewWidthHeight": @(self.pictureViewWidthHeight),
                              @"buttonWidthHeight": @(self.buttonWidthHeight),
                              @"betweenButtonPadding": @(self.betweenButtonPadding),
                              @"hLeftPadding": @(self.hLeftPadding),
                              @"hRightPadding": @(self.hRightPadding),
                              @"vPicturePadding": @(self.vPicturePadding),
                              };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hLeftPadding-[pictureView(==pictureViewWidthHeight)]-10-[textContainer]-10-[dismissButton(==buttonWidthHeight)]-(betweenButtonPadding)-[sendButton(==buttonWidthHeight)]-hRightPadding-|" options:0 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pictureView(==pictureViewWidthHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pictureView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hLeftPadding-[initialsInsteadOfPictureView(==pictureViewWidthHeight)]-10-[textContainer]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[initialsInsteadOfPictureView(==pictureViewWidthHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsInsteadOfPictureView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textContainer attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[dismissButton(==buttonWidthHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dismissButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sendButton(==buttonWidthHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.inviteButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];


    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pictureView]-10-[bottomSeparator]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparator(==0.5)]-0-|" options:0 metrics:metrics views:views]];

    // inside text container
    [self.textContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[nameLabel]-4-[subtitleLabel]-0-|" options:0 metrics:metrics views:views]];
    [self.textContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[nameLabel]-0-|" options:0 metrics:metrics views:views]];
    [self.textContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[subtitleLabel]-0-|" options:0 metrics:metrics views:views]];

}

- (void)updateConstraints {
    [super updateConstraints];
    if (!_setupInitialConstraints) {
        [self setupInitialConstraints];
        _setupInitialConstraints = YES;
    }
}

- (CGFloat)cellHeight {
    return ceil(self.vPicturePadding * 2 + self.pictureViewWidthHeight);
}

- (void)moveToInviteSentState {
    self.subtitleLabel.text = @"Invite Sent!";
    self.subtitleLabel.textColor = self.highlightColor;
}

- (void)updateForUseWithContact:(MAVEABPerson *)contact dismissBlock:(void (^)())dismissBlock inviteBlock:(void (^)())inviteBlock {
    UIImage *picture = [contact picture];
    [self _updatePictureViewWithPicture:picture orInitials:[contact initials]];
    self.nameLabel.text = [contact fullName];
    self.bottomSeparator.hidden = NO;
    self.subtitleLabel.textColor = [UIColor colorWithWhite:167.0/255 alpha:1.0];
    [self _setNumberContactsLabelText:contact.numberFriendsOnApp];
    self.dismissButton.dismissBlock = dismissBlock;
    [self.inviteButton resetButtonNotClicked];
    self.inviteButton.sendInviteBlock = inviteBlock;
}

- (void)_setNumberContactsLabelText:(NSUInteger)numberFriends {
    NSString *pluralSingularFriend = numberFriends == 1 ? @"friend" : @"friends";
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ %@ on app", @(numberFriends), pluralSingularFriend];
}

- (void)_updatePictureViewWithPicture:(UIImage *)picture orInitials:(NSString *)initials {
    if (picture) {
        self.pictureView.image = picture;
        self.pictureView.hidden = NO;
        self.initialsInsteadOfPictureView.hidden = YES;
    } else {
        self.pictureView.image = nil;
        self.pictureView.hidden = YES;
        self.initialsInsteadOfPictureView.hidden = NO;
        self.initialsInsteadOfPictureView.label.text = initials;
    }
}

@end
