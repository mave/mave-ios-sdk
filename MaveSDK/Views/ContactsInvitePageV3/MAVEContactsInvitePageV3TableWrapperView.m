//
//  MAVEContactsInvitePageV3TableWrapperView.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import "MAVEContactsInvitePageV3TableWrapperView.h"

@implementation MAVEContactsInvitePageV3TableWrapperView {
    BOOL _didInitialUpdateConstraints;
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
    self.backgroundColor = [UIColor whiteColor];
    self.aboveTableView = [[UIView alloc] init];
    self.aboveTableView.backgroundColor = [UIColor purpleColor];
    self.searchBar = [[MAVESearchBar alloc] initWithSingletonSearchBarDisplayOptions];
    self.selectAllEmailsRow = [[MAVEInvitePageSelectAllRow alloc] init];
    self.selectAllEmailsRow.textLabel.text = @"Select All Emails";
    self.topLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.aboveTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];

    self.tableView = [[UITableView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.separatorColor = UITableViewCellSeparatorStyleNone;
    self.searchTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.searchTableView.hidden = YES;

    self.bigSendButton = [[MAVEBigSendButton alloc] init];
    self.bigSendButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.extraBottomPadding = [[UIView alloc] init];
    self.extraBottomPadding.translatesAutoresizingMaskIntoConstraints = NO;

    self.bigSendButtonHeightWhenExpanded = 60;
    self.bigSendButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.bigSendButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.extraBottomPadding attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self updateBigSendButtonHeightExpanded:NO animated:NO];
    self.extraBottomPaddingHeightConstraint = [NSLayoutConstraint constraintWithItem:self.extraBottomPadding attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];

    self.aboveTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.aboveTableView];
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectAllEmailsRow.translatesAutoresizingMaskIntoConstraints = NO;
    [self.aboveTableView addSubview:self.searchBar];
    [self.aboveTableView addSubview:self.selectAllEmailsRow];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.searchTableView];
    [self addSubview:self.tableView];
    [self addSubview:self.bigSendButton];
    [self addSubview:self.extraBottomPadding];

    [self setNeedsUpdateConstraints];
}

- (void)setupInitialConstraints {
    NSDictionary *views = @{@"aboveTableView": self.aboveTableView,
                            @"tableView": self.tableView,
                            @"bigSendButton": self.bigSendButton,
                            @"extraBottomPadding": self.extraBottomPadding,
                            @"searchBar": self.searchBar,
                            @"selectAllRow": self.selectAllEmailsRow};
    NSDictionary *metrics = @{@"searchBarHeight": @(MAVESearchBarHeight + 20),
                              @"bigSendButtonHeight": @(self.bigSendButtonHeightWhenExpanded)};

    // the constraints that are editable later
    [self addConstraint:self.topLayoutConstraint];
    [self addConstraint:self.bigSendButtonBottomConstraint];
    [self addConstraint:self.extraBottomPaddingHeightConstraint];
    // rest of wrapper constraints
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[aboveTableView]-0-[tableView]-0-[bigSendButton(==bigSendButtonHeight)]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[extraBottomPadding]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[aboveTableView]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bigSendButton]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[extraBottomPadding]-0-|" options:0 metrics:metrics views:views]];

    // Constraints internal to above table view
    [self.aboveTableView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[searchBar]-0-[selectAllRow(44)]-0-|" options:0 metrics:metrics views:views]];
    [self.aboveTableView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBar]-0-|" options:0 metrics:metrics views:views]];
    [self.aboveTableView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[selectAllRow]-0-|" options:0 metrics:metrics views:views]];
}

- (void)updateConstraints {
    if (!_didInitialUpdateConstraints) {
        [self setupInitialConstraints];
        _didInitialUpdateConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.searchTableView.frame = self.tableView.frame;
}

- (void)updateBigSendButtonHeightExpanded:(BOOL)expanded animated:(BOOL)animated {
    CGFloat valWhenExpanded = 0;
    CGFloat valWhenCompressed = self.bigSendButtonHeightWhenExpanded;
    BOOL needAnimate = NO;
    if (expanded && self.bigSendButtonBottomConstraint.constant != valWhenExpanded) {
        self.bigSendButtonBottomConstraint.constant = valWhenExpanded;
        if (animated) {
            needAnimate = YES;
        }
    } else if (!expanded && self.bigSendButtonBottomConstraint.constant != valWhenCompressed) {
        self.bigSendButtonBottomConstraint.constant = valWhenCompressed;
        if (animated) {
            needAnimate = YES;
        }
    }
    if (needAnimate) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

@end
