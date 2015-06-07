//
//  MAVESuggestedInviteSingleTableViewCell.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/5/15.
//
//

#import "MAVESuggestedInviteReusableTableViewCell.h"

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
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.pictureView = [[UIImageView alloc] init];
    self.pictureView.backgroundColor = [UIColor orangeColor];
    self.pictureView.layer.cornerRadius = self.pictureViewWidthHeight / 2;
    self.pictureView.layer.masksToBounds = YES;
    self.initialsInsteadOfPictureView = [[MAVEInitialsPictureAlternative alloc] init];
    self.initialsInsteadOfPictureView.layer.cornerRadius = self.pictureViewWidthHeight / 2;
    self.initialsInsteadOfPictureView.layer.masksToBounds = YES;
    self.initialsInsteadOfPictureView.hidden = YES;
    self.textContainer = [[UIView alloc] init];
    self.textContainer.backgroundColor = [UIColor blueColor];
    self.nameLabel = [[UILabel alloc] init];
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.textColor = [UIColor colorWithWhite:167.0/255 alpha:1.0];
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dismissButton.backgroundColor = [UIColor greenColor];
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.backgroundColor = [UIColor purpleColor];

    self.pictureViewWidthHeight = 80;
    self.buttonWidthHeight = 25;
    self.hOuterPadding = 8;
    self.vPicturePadding = 6;

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
                              @"hOuterPadding": @(self.hOuterPadding),
                              @"vPicturePadding": @(self.vPicturePadding),
                              };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hOuterPadding-[pictureView(==pictureViewWidthHeight)]-10-[textContainer]-10-[dismissButton(==buttonWidthHeight)]-10-[sendButton(==buttonWidthHeight)]-hOuterPadding-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pictureView]-10-[subtitleLabel]-[dismissButton]" options:0 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pictureView(==pictureViewWidthHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pictureView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
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
