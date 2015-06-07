//
//  MAVESuggestedInviteSingleTableViewCell.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/5/15.
//
//

#import "MAVESuggestedInviteReusableTableViewCell.h"
#import "MAVEDisplayOptions.h"

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
    self.pictureViewWidthHeight = 70;
    self.buttonWidthHeight = 34;
    self.betweenButtonPadding = 20;
    self.hLeftPadding = 8;
    self.hRightPadding = 20;
    self.vPicturePadding = 6;

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
    self.subtitleLabel.textColor = [UIColor colorWithWhite:167.0/255 alpha:1.0];
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dismissButton.layer.borderColor = [[MAVEDisplayOptions colorAppleMediumGray] CGColor];
    self.dismissButton.layer.borderWidth = 1.0f;
    self.dismissButton.layer.cornerRadius = self.buttonWidthHeight / 2;
    self.dismissButton.layer.masksToBounds = YES;
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.layer.borderColor = [[MAVEDisplayOptions colorAppleMediumGray] CGColor];
    self.sendButton.layer.borderWidth = 1.0f;
    self.sendButton.layer.cornerRadius = self.buttonWidthHeight / 2;
    self.sendButton.layer.masksToBounds = YES;


    self.pictureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.initialsInsteadOfPictureView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.pictureView];
    [self.contentView addSubview:self.initialsInsteadOfPictureView];
    [self.contentView addSubview:self.textContainer];
    [self.textContainer addSubview:self.nameLabel];
    [self.textContainer addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.dismissButton];
    [self.contentView addSubview:self.sendButton];

    [self setNeedsUpdateConstraints];
}

- (void)setupInitialConstraints {
    NSDictionary *views = @{@"pictureView": self.pictureView,
                            @"initialsInsteadOfPictureView": self.initialsInsteadOfPictureView,
                            @"textContainer": self.textContainer,
                            @"nameLabel": self.nameLabel,
                            @"subtitleLabel": self.subtitleLabel,
                            @"dismissButton": self.dismissButton,
                            @"sendButton": self.sendButton};
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
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

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
    return self.vPicturePadding * 2 + self.pictureViewWidthHeight;
}

- (void)updateForUseWithContact:(MAVEABPerson *)contact {
    UIImage *picture = [contact picture];
    [self _updatePictureViewWithPicture:picture orInitials:[contact initials]];
    self.nameLabel.text = [contact fullName];
    self.subtitleLabel.text = @"10 friends on App";
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
