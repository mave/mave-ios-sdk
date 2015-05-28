//
//  MAVEContactsInvitePageV3Cell.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import "MAVEContactsInvitePageV3Cell.h"
#import "MAVECustomContactInfoRowV3.h"
#import "MAVEContactPhoneNumber.h"
#import "MAVEContactEmail.h"

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
    self.nameLabelToContactInfoWrapper = 2;
    self.contactInfoWrapperToBottom = 8;
    self.contactInfoWrapperCollapsedHeight = 4;
    self.bottomSeparatorHeight = 0.5;
    self.contactInfoFont = [UIFont systemFontOfSize:14];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.isExpanded = NO;
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

    self.bottomSeparator = [[UIView alloc] init];
    self.bottomSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];

    [self.contentView addSubview:self.picture];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.checkmarkBox];
    [self.contentView addSubview:self.contactInfoContainer];
    [self.contentView addSubview:self.bottomSeparator];

    // create the constraint that we add/remove to expand/contract the cell, but don't do anything with it yet
    self.overridingContactInfoContainerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.contactInfoContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.contactInfoWrapperCollapsedHeight];
    self.overridingContactInfoContainerHeightConstraint.priority = 750;

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
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topToNameLabel-[nameLabel]-(nameLabelToContactInfoWrapper@249)-[contactInfoContainer]-contactInfoWrapperToBottom-[bottomSeparator(==bottomSeparatorHeight)]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[checkmarkBox(==checkboxHeight)]" options:0 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[picture]-12-[contactInfoContainer]-(>=10)-[checkmarkBox]" options:0 metrics:metrics views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[picture]-12-[bottomSeparator]-0-|" options:0 metrics:metrics views:views]];
}

- (void)setIsExpanded:(BOOL)isExpanded {
    _isExpanded = isExpanded;
    self.contactInfoContainer.hidden = !isExpanded;
    if (!isExpanded) {
        [self.contactInfoContainer addConstraint:self.overridingContactInfoContainerHeightConstraint];
    } else {
        [self.contactInfoContainer removeConstraint:self.overridingContactInfoContainerHeightConstraint];
    }
}

- (void)updateConstraints {
    if (!_didSetupInitialConstraints) {
        [self setupInitialConstraints];
        _didSetupInitialConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isExpanded != self.person.selected) {
        // if cell is expanding now, delay the contact info showing up a short time so that it shows up once
        // the cell is big enough for it. When compressing, do the opposite - have it disappear immediately
        // right when the cell begins to shrink.
        if (self.person.selected) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isExpanded = self.person.selected;
            });
        } else {
            self.isExpanded = self.person.selected;
        }
        [self.checkmarkBox animateToggleCheckmark];
    }
}

// Calculating what height will be
- (CGFloat)heightGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords {
    CGFloat nameLabelHeight = [@"Some Name" sizeWithAttributes:@{NSFontAttributeName: self.nameLabel.font}].height;
    CGFloat contactInfoWrapperHeight = [self _heightOfContactInfoWrapperGivenNumberOfContactInfoRecords:numberContactRecords];
    return self.topToNameLabel + nameLabelHeight + self.nameLabelToContactInfoWrapper + contactInfoWrapperHeight + self.contactInfoWrapperToBottom + self.bottomSeparatorHeight;
}
- (CGFloat)_heightOfContactInfoWrapperGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords {
    if (numberContactRecords < 1) {
        return self.contactInfoWrapperCollapsedHeight;
    }
    CGFloat eachRecordHeight = [MAVECustomContactInfoRowV3 heightGivenFont:self.contactInfoFont];
    return numberContactRecords * eachRecordHeight;
}

- (void)updateForReuseWithPerson:(MAVEABPerson *)person {
    self.person = person;
    self.nameLabel.text = [person fullName];
    self.isExpanded = person.selected;
    self.checkmarkBox.isChecked = person.selected;
    [self updateWithContactInfoFromPerson:person];
}

- (void)updateWithContactInfoFromPerson:(MAVEABPerson *)person {
    // TODO: Lots of tests reusing a cell making sure these contact info rows get
    // laid out appropriately. Try when going from more to less and less to more.
    //

    NSArray *sortedRecords = [person rankedContactIdentifiers];
    NSInteger numberOfRowsNeeded = [sortedRecords count];
    if (numberOfRowsNeeded == 0) {
        return;
    }
    NSArray *currentRowsToReuse = [self.contactInfoContainer subviews];
    NSInteger numberOfReusableRows = [currentRowsToReuse count];

    MAVECustomContactInfoRowV3 *previousContactInfoRow = nil;
    MAVEContactIdentifierBase *record = nil;
    for (NSUInteger i = 0; i < [sortedRecords count]; ++i) {
        record = [sortedRecords objectAtIndex:i];

        MAVECustomContactInfoRowV3 *contactInfoRow;
        if (numberOfReusableRows >= i+1) {
            contactInfoRow = [currentRowsToReuse objectAtIndex:i];
        } else {
            contactInfoRow = [[MAVECustomContactInfoRowV3 alloc] initWithFont:self.contactInfoFont selectedColor:[UIColor blueColor] deselectedColor:[UIColor grayColor]];
            contactInfoRow.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contactInfoContainer addSubview:contactInfoRow];
            [self setConstraintsForContactInfoRow:contactInfoRow rowAbove:previousContactInfoRow];
        }
        [contactInfoRow updateWithContactIdentifierRecord:record];
        __weak MAVEContactsInvitePageV3Cell *weakSelf = self;
        __weak MAVECustomContactInfoRowV3 *weakRowSelf = contactInfoRow;
        contactInfoRow.rowWasTappedBlock = ^void(BOOL isSelected) {
            weakRowSelf.contactIdentifierRecord.selected = isSelected;
            if (self.contactIdentifiersSelectedDidUpdateBlock) {
                self.contactIdentifiersSelectedDidUpdateBlock(person);
            }

            if (![person isAtLeastOneContactIdentifierSelected]) {
                person.selected = NO;
                [weakSelf setNeedsUpdateConstraints];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[weakSelf containingTableView] beginUpdates];
                    [[weakSelf containingTableView] endUpdates];
                });
            }
        };

        previousContactInfoRow = contactInfoRow;
    }
    if (numberOfReusableRows > numberOfRowsNeeded) {
        for (NSUInteger i = numberOfRowsNeeded; i < numberOfReusableRows; ++i) {
            UIView *row = [currentRowsToReuse objectAtIndex:i];
            [row removeFromSuperview];
        }
    }

    if (self.bottomContactInfoToContainerBottomConstraint) {
        [self.contactInfoContainer removeConstraint:self.bottomContactInfoToContainerBottomConstraint];
        self.bottomContactInfoToContainerBottomConstraint = nil;
    }
    self.bottomContactInfoToContainerBottomConstraint = [NSLayoutConstraint constraintWithItem:previousContactInfoRow attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contactInfoContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    self.bottomContactInfoToContainerBottomConstraint.priority = 250;
    [self.contactInfoContainer addConstraint:self.bottomContactInfoToContainerBottomConstraint];

    [self setNeedsLayout];
}

- (void)setConstraintsForContactInfoRow:(MAVECustomContactInfoRowV3 *)contactInfoRow rowAbove:(MAVECustomContactInfoRowV3 *)rowAbove {
    [self.contactInfoContainer addConstraint:[NSLayoutConstraint constraintWithItem:contactInfoRow attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contactInfoContainer attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.contactInfoContainer addConstraint:[NSLayoutConstraint constraintWithItem:contactInfoRow attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contactInfoContainer attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];

    // Vertical constraints should be lower priority so we can override with a constant near zero height when cell is collapsed
    NSLayoutConstraint *constraintTop;
    if (rowAbove) {
        constraintTop = [NSLayoutConstraint constraintWithItem:contactInfoRow attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rowAbove attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        constraintTop.priority = 1000;
    } else {
        constraintTop = [NSLayoutConstraint constraintWithItem:contactInfoRow attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contactInfoContainer attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        constraintTop.priority = 250;
    }
    [self.contactInfoContainer addConstraint:constraintTop];
}

- (UITableView *)containingTableView {
    id view = [self superview];
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    return (UITableView *)view;
}


@end
