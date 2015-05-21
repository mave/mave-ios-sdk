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

- (void)doInitialSetup {
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor blueColor];
    self.bigSendButton = [[UIButton alloc] init];
    self.bigSendButton.backgroundColor = [UIColor greenColor];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    self.bigSendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];

    [self setNeedsUpdateConstraints];
}

- (void)setupInitialConstraints {
    // Vertical constraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bigSendButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    self.bigSendButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.bigSendButtonHeightConstraint attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
    [self addConstraint:self.bigSendButtonHeightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bigSendButtonHeightConstraint attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];

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
