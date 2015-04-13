//
//  MAVEContactsInvitePageV2TableViewCell2.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/9/15.
//
//

#import "MAVEContactsInvitePageV2TableViewCell.h"
#import "MaveSDK.h"

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
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.contactInfoWrapper];
    [self.contactInfoWrapper addSubview:self.nameLabel];
    [self.contactInfoWrapper addSubview:self.detailLabel];
    [self.contentView addSubview:self.sendButton];
}

- (void)doStylingSetup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;

    self.backgroundColor = opts.contactCellBackgroundColor;

    self.nameLabel.font = opts.contactNameFont;
    self.nameLabel.textColor = opts.contactNameTextColor;
    self.detailLabel.font = opts.contactDetailsFont;
    self.detailLabel.textColor = opts.contactDetailsTextColor;

    self.sendButton.titleLabel.font = opts.contactInlineSendButtonFont;
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:opts.contactInlineSendButtonTextColor forState:UIControlStateNormal];
    [self.sendButton setTitle:@"Sending..." forState:UIControlStateSelected];
    [self.sendButton setTitleColor:opts.contactInlineSendButtonDisabledTextColor forState:UIControlStateSelected];
    [self.sendButton setTitle:@"Sent" forState:UIControlStateDisabled];
    [self.sendButton setTitleColor:opts.contactInlineSendButtonDisabledTextColor forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(sendInviteToCurrentPerson) forControlEvents:UIControlEventTouchUpInside];
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
    NSDictionary *marginMetrics = @{@"topMargin": @(8),
                                    @"nameToDetailsMargin": @(0),
                                    @"bottomMargin": @(8),
                                    @"leftMargin": @(10)};

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

    NSString *fsNameDetailsV = @"V:|-topMargin-[nameLabel]-nameToDetailsMargin-[detailsLabel]-8-|";
    NSString *fsNameH = @"H:|-leftMargin-[nameLabel]";
    NSString *fsDetailsH = @"H:|-leftMargin-[detailsLabel]";
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
    // On this table we use the selected field to mean already sent, since it's one-click
    // send instead of selecting people
    if (person.selected) {
        self.sendButton.selected = NO;
        self.sendButton.enabled = NO;
    } else {
        self.sendButton.enabled = YES;
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
        [self.delegateController sendInviteToPerson:self.person sendButton:self.sendButton];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
