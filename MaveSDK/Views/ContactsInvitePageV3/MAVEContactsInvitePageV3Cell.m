//
//  MAVEContactsInvitePageV3Cell.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import "MAVEContactsInvitePageV3Cell.h"
#import "MAVECustomContactInfoRowV3.h"

@implementation MAVEContactsInvitePageV3Cell {
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
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    self.topToNameLabel = 12;
    self.nameLabelToContactInfoWrapper = 4;
    self.contactInfoWrapperToBottom = 8;
    self.contactInfoHeightSpacingBetweenRows = 8;
    self.bottomSeparatorHeight = 0.5;
    self.contactInfoFont = [UIFont systemFontOfSize:14];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.pictureWidthHeight = 30;
    self.picture = [[UIImageView alloc] init];
    self.picture.translatesAutoresizingMaskIntoConstraints = NO;
    self.picture.backgroundColor = [UIColor grayColor];
    self.picture.layer.cornerRadius = self.pictureWidthHeight / 2;
    self.picture.layer.masksToBounds = YES;

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.font = [UIFont fontWithName:@"OpenSans" size:18];

    self.checkmarkBox = [[MAVECustomCheckboxV3 alloc] init];
    self.checkmarkBox.translatesAutoresizingMaskIntoConstraints = NO;

    self.contactInfoContainer = [[UIView alloc] init];
    self.contactInfoContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.contactInfoContainer.backgroundColor = [UIColor greenColor];

    self.bottomSeparator = [[UIView alloc] init];
    self.bottomSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomSeparator.backgroundColor = [UIColor grayColor];

    [self.contentView addSubview:self.picture];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.checkmarkBox];
    [self.contentView addSubview:self.contactInfoContainer];
    [self.contentView addSubview:self.bottomSeparator];

    [self setNeedsUpdateConstraints];
}

- (void)setupInitialConstraints {
    CGFloat checkboxWidthHeight = self.checkmarkBox.intrinsicContentSize.width;
    NSDictionary *metrics = @{@"pictureHeight": @(self.pictureWidthHeight),
                              @"checkboxHeight": @(checkboxWidthHeight),
                              @"topToNameLabel": @(self.topToNameLabel),
                              @"nameLabelToContactInfoWrapper": @(self.nameLabelToContactInfoWrapper),
                              @"contactInfoWrapperToBottom": @(self.contactInfoWrapperToBottom),
                              @"bottomSeparatorHeight": @(self.bottomSeparatorHeight),
    };
    NSDictionary *viewsWithSelf = NSDictionaryOfVariableBindings(self.picture, self.nameLabel, self.checkmarkBox, self.contactInfoContainer, self.bottomSeparator);
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithCapacity:[viewsWithSelf count]];
    for (NSString *key in viewsWithSelf) {
        NSString *newKey = [key stringByReplacingOccurrencesOfString:@"self." withString:@""];
        [tmp setObject:[viewsWithSelf objectForKey:key] forKey:newKey];
    }
    
    NSDictionary *views = [NSDictionary dictionaryWithDictionary:tmp];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[picture(==pictureHeight)]-12-[nameLabel]-20-[checkmarkBox(==checkboxHeight)]-32-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[picture(==pictureHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topToNameLabel-[nameLabel]-nameLabelToContactInfoWrapper-[contactInfoContainer]-contactInfoWrapperToBottom-[bottomSeparator(==bottomSeparatorHeight)]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[checkmarkBox(==checkboxHeight)]" options:0 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[picture]-12-[contactInfoContainer]-(>=10)-[checkmarkBox]" options:0 metrics:metrics views:views]];
    NSLayoutConstraint *weakEmptyContactInfoHeight = [NSLayoutConstraint constraintWithItem:self.contactInfoContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    weakEmptyContactInfoHeight.priority = 250;
    [self.contactInfoContainer addConstraint:weakEmptyContactInfoHeight];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[picture]-12-[bottomSeparator]-0-|" options:0 metrics:metrics views:views]];
}

- (void)updateConstraints {
    if (!_didSetupInitialConstraints) {
        [self setupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}

// Calculating what height will be
- (CGFloat)heightGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords {
    CGFloat nameLabelHeight = [@"Some Name" sizeWithAttributes:@{NSFontAttributeName: self.nameLabel.font}].height;
    CGFloat contactInfoWrapperHeight = [self _heightOfContactInfoWrapperGivenNumberOfContactInfoRecords:numberContactRecords];
    return self.topToNameLabel + nameLabelHeight + self.nameLabelToContactInfoWrapper + contactInfoWrapperHeight + self.contactInfoWrapperToBottom + self.bottomSeparatorHeight;
}
- (CGFloat)_heightOfContactInfoWrapperGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords {
    if (numberContactRecords < 1) {
        return 10;
    }
    CGFloat eachRecordHeight = [MAVECustomContactInfoRowV3 heightGivenFont:self.contactInfoFont];
    return numberContactRecords * eachRecordHeight + (numberContactRecords - 1) * self.contactInfoHeightSpacingBetweenRows;
}

- (void)updateForReuseWithPerson:(MAVEABPerson *)person {
    self.nameLabel.text = [person fullName];
    [self updateWithContactInfoFromPerson:person];
}

- (void)updateWithContactInfoFromPerson:(MAVEABPerson *)person {
    // Clear out any existing views
    // TODO
    for (UIView *view in [self.contactInfoContainer subviews]) {
        [view removeFromSuperview];
    }

    NSInteger numPhoneNumbers = [person.phoneNumbers count];
    if (numPhoneNumbers == 0) {
        return;
    }

    NSDictionary *labelMappings = @{@"_$!<Mobile>!$_": @"cell",
                                    @"_$!<Main>!$_": @"main",
                                    @"_$!<Other>!$_": @"main",
                                    @"_$!<Home>!$_": @"home",
                                    @"_$!<Work>!$_": @"work",
    };
    MAVECustomContactInfoRowV3 *previousContactInfoRow = nil;
    for (NSUInteger i = 0; i < [person.phoneNumbers count]; ++i) {
        NSString *phoneRaw = [person.phoneNumbers objectAtIndex:i];
        NSString *categoryRaw = [person.phoneNumberLabels objectAtIndex:i];
        NSString *displayCategory = [labelMappings objectForKey:categoryRaw];
        if (!displayCategory) {
            displayCategory = @"other";
        }
        NSString *displayPhone = [MAVEABPerson displayPhoneNumber:phoneRaw];
        NSString *labelText = [NSString stringWithFormat:@"%@ (%@)", displayPhone, displayCategory];
        NSLog(@"phones are: %@", labelText);

        MAVECustomContactInfoRowV3 *contactInfoRow = [[MAVECustomContactInfoRowV3 alloc] initWithFont:self.contactInfoFont selectedColor:[UIColor blueColor] deselectedColor:[UIColor grayColor]];
        contactInfoRow.translatesAutoresizingMaskIntoConstraints = NO;
        [contactInfoRow updateWithLabelText:labelText isSelected:NO];

        [self.contactInfoContainer addSubview:contactInfoRow];
        [self.contactInfoContainer addConstraint:[NSLayoutConstraint constraintWithItem:contactInfoRow attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contactInfoContainer attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self.contactInfoContainer addConstraint:[NSLayoutConstraint constraintWithItem:contactInfoRow attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contactInfoContainer attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];

        if (previousContactInfoRow) {
            [self.contactInfoContainer addConstraint:[NSLayoutConstraint constraintWithItem:contactInfoRow attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousContactInfoRow attribute:NSLayoutAttributeBottom multiplier:1 constant:self.contactInfoHeightSpacingBetweenRows]];
        } else {
            [self.contactInfoContainer addConstraint:[NSLayoutConstraint constraintWithItem:contactInfoRow attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contactInfoContainer attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        }

        previousContactInfoRow = contactInfoRow;
    }
    [self.contactInfoContainer addConstraint:[NSLayoutConstraint constraintWithItem:previousContactInfoRow attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contactInfoContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];

    [self setNeedsLayout];
}



@end
