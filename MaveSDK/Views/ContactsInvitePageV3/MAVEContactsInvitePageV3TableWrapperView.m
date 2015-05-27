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
    self.tableView = [[UITableView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.bigSendButton = [[MAVEBigSendButton alloc] init];
//    self.bigSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.bigSendButton.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
//    self.bigSendButton.tintColor = [UIColor whiteColor];
//    [self setButtonTextNumberOfInvitesToSend:4];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    self.bigSendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bigSendButton];

    [self setNeedsUpdateConstraints];
}

- (void)setButtonTextNumberOfInvitesToSend:(NSUInteger)number {
    NSString *noun = number == 1 ? @"Invite" : @"Invites";
    NSString *text = [NSString stringWithFormat:@"Send %@ %@", @(number), noun];
    [self.bigSendButton setTitle:text forState:UIControlStateNormal];
}

- (void)setupInitialConstraints {
    // Vertical constraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bigSendButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    self.bigSendButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.bigSendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60];
    [self addConstraint:self.bigSendButtonHeightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bigSendButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];

    // Horizontal constraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bigSendButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bigSendButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
}

- (void)updateConstraints {
    if (!_didInitialUpdateConstraints) {
        [self setupInitialConstraints];
        _didInitialUpdateConstraints = YES;
    }
    [super updateConstraints];
}

@end
