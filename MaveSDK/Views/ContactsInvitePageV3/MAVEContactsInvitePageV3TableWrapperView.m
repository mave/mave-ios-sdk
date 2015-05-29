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
    self.selectAllRow = [[MAVEInvitePageSelectAllRow alloc] init];
    self.selectAllRow.textLabel.text = @"Select All Emails";
    self.topLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.aboveTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];

    self.tableView = [[UITableView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.separatorColor = UITableViewCellSeparatorStyleNone;
    self.searchTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.searchTableView.hidden = YES;

    self.bigSendButton = [[MAVEBigSendButton alloc] init];
    self.bigSendButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.bigSendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];

    self.aboveTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.aboveTableView];
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectAllRow.translatesAutoresizingMaskIntoConstraints = NO;
    [self.aboveTableView addSubview:self.searchBar];
    [self.aboveTableView addSubview:self.selectAllRow];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    [self addSubview:self.searchTableView];
    self.bigSendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bigSendButton];

    [self setNeedsUpdateConstraints];
}

- (void)setupInitialConstraints {
    NSDictionary *views = @{@"aboveTableView": self.aboveTableView,
                            @"tableView": self.tableView,
                            @"bigSendButton": self.bigSendButton,
                            @"searchBar": self.searchBar,
                            @"selectAllRow": self.selectAllRow};
    NSDictionary *metrics = @{@"searchBarHeight": @(MAVESearchBarHeight + 20)};

    // the constraints that are editable later
    [self addConstraint:self.topLayoutConstraint];
    [self addConstraint:self.bigSendButtonHeightConstraint];
    // rest of wrapper constraints
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[aboveTableView]-0-[tableView]-0-[bigSendButton]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[aboveTableView]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bigSendButton]-0-|" options:0 metrics:metrics views:views]];

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

- (void)updateBigSendButtonHeightExpanded:(BOOL)expanded {
    CGFloat expandedHeight = 60;
    CGFloat compressedHeight = 0;
    BOOL needAnimate = NO;
    if (expanded && self.bigSendButtonHeightConstraint.constant != expandedHeight) {
        self.bigSendButtonHeightConstraint.constant = expandedHeight;
        needAnimate = YES;
    } else if (!expanded && self.bigSendButtonHeightConstraint.constant != compressedHeight) {
        self.bigSendButtonHeightConstraint.constant = compressedHeight;
        needAnimate = YES;
    }
    if (needAnimate) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

@end
