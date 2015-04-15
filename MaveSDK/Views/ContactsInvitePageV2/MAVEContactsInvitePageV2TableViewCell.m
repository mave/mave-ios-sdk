//
//  MAVEContactsInvitePageV2TableViewCell2.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/9/15.
//
//

#import "MAVEContactsInvitePageV2TableViewCell.h"
#import "MaveSDK.h"

CGFloat const MAVEV2CellLeftMargin = 14;
CGFloat const MAVEV2CellTopMargin = 8;
CGFloat const MAVEV2CellBottomMargin = 8;
CGFloat const MAVEV2CellNameToDetailsMargin = 0;

@implementation MAVEContactsInvitePageV2TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    style = UITableViewCellStyleDefault;
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        [self doCreateSubviews];
        [self doStylingSetup];
        [self doConstraintSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [self doStylingSetup];
}

- (void)doCreateSubviews {
    self.contactInfoWrapper = [[UIView alloc] init];
    self.nameLabel = [[UILabel alloc] init];
    self.detailLabel = [[UILabel alloc] init];
    self.sendButton = [[MAVEContactsInvitePageInlineSendButton alloc] init];
    [self.contentView addSubview:self.contactInfoWrapper];
    [self.contactInfoWrapper addSubview:self.nameLabel];
    [self.contactInfoWrapper addSubview:self.detailLabel];
    [self.contentView addSubview:self.sendButton];
}

- (void)doStylingSetup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;

    self.backgroundColor = opts.contactCellBackgroundColor;

    self.nameLabel.font = [[self class] nameFont];
    self.nameLabel.textColor = opts.contactNameTextColor;
    self.detailLabel.font = [[self class] detailsFont];
    self.detailLabel.textColor = opts.contactDetailsTextColor;

    [self.sendButton addTarget:self action:@selector(sendInviteToCurrentPerson) forControlEvents:UIControlEventTouchUpInside];
}

+ (UIFont *)nameFont {
    return [MaveSDK sharedInstance].displayOptions.contactNameFont;
}

+ (UIFont *)detailsFont {
    return [MaveSDK sharedInstance].displayOptions.contactDetailsFont;
}

// Name and details are both always one row, so we don't need the actual content of the cell to
// figure out their heights, any string will be the same.
+ (CGFloat)heightCellWithHave {
    CGFloat nameHeight = [@"Tg" sizeWithAttributes:@{NSFontAttributeName: [self nameFont]}].height;
    CGFloat detailsHeight = [@"Tg" sizeWithAttributes:@{NSFontAttributeName: [self detailsFont]}].height;
    return MAVEV2CellTopMargin + nameHeight + MAVEV2CellNameToDetailsMargin + detailsHeight + MAVEV2CellBottomMargin;
}

- (void)doConstraintSetup {
    self.contactInfoWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *viewsDict = @{@"contentView": self.contentView,
                                @"contactInfoWrapper": self.contactInfoWrapper,
                                @"nameLabel": self.nameLabel,
                                @"detailsLabel": self.detailLabel,
                                @"sendButton": self.sendButton};
    NSDictionary *marginMetrics = @{@"topMargin": @(MAVEV2CellTopMargin),
                                    @"nameToDetailsMargin": @(MAVEV2CellNameToDetailsMargin),
                                    @"bottomMargin": @(MAVEV2CellBottomMargin),
                                    @"leftMargin": @(MAVEV2CellLeftMargin)};

    NSString *fsOuterLevelV = @"V:|-0-[contactInfoWrapper]-0-|";
    NSString *fsOuterLevelH = @"H:|-0-[contactInfoWrapper]-10-[sendButton]";
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fsOuterLevelV options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fsOuterLevelH options:0 metrics:nil views:viewsDict]];
    NSLayoutConstraint *wrapperWidthConstraint =
    [NSLayoutConstraint constraintWithItem:self.contactInfoWrapper
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                 attribute:NSLayoutAttributeWidth
                                multiplier:0.68
                                  constant:0];
    [self.contentView addConstraint:wrapperWidthConstraint];

    NSString *fsNameDetailsV = @"V:|-topMargin-[nameLabel]-nameToDetailsMargin-[detailsLabel]-bottomMargin-|";
    NSString *fsNameH = @"H:|-leftMargin-[nameLabel]-(>=0)-|";
    NSString *fsDetailsH = @"H:|-leftMargin-[detailsLabel]-(>=0)-|";
    [self.contactInfoWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fsNameDetailsV options:0 metrics:marginMetrics views:viewsDict]];
    [self.contactInfoWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fsNameH options:0 metrics:marginMetrics views:viewsDict]];
    [self.contactInfoWrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:fsDetailsH options:0 metrics:marginMetrics views:viewsDict]];

    NSLayoutConstraint *vCenterButtonConstraint =
    [NSLayoutConstraint constraintWithItem:self.sendButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.contentView addConstraint:vCenterButtonConstraint];
}

- (void)updateWithInfoForPerson:(MAVEABPerson *)person {
    self.person = person;
    self.nameLabel.text = [person fullName];
    self.detailLabel.text = [MAVEABPerson displayPhoneNumber:person.bestPhone];
    self.sendButton.hidden = NO;

    // Set the state of the send button based on the person's sending status
    switch (person.sendingStatus) {
        case MAVEInviteSendingStatusUnsent: {
            [self.sendButton setStatusUnsent];
            break;
        }
        case MAVEInviteSendingStatusSending: {
            [self.sendButton setStatusSending];
            break;
        }
        case MAVEInviteSendingStatusSent: {
            [self.sendButton setStatusSent];
            break;
        }
    }
}

- (void)updateWithInfoForNoPersonFound {
    self.person = nil;
    self.nameLabel.text = @"No results found";
    self.detailLabel.text = nil;
    self.sendButton.hidden = YES;
}

- (void)sendInviteToCurrentPerson {
    if (self.delegateController) {
        [self.delegateController sendInviteToPerson:self.person];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
