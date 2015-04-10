//
//  MAVEContactsInvitePageV2TableViewCell2.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/9/15.
//
//

#import "MAVEContactsInvitePageV2TableViewCell2.h"

@implementation MAVEContactsInvitePageV2TableViewCell2

- (void)awakeFromNib {
    [self doInitialSetup];
}

- (void)doInitialSetup {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.sendButton.titleLabel.textColor = [UIColor blueColor];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.sendButton setTitle:@"Sending..." forState:UIControlStateSelected];
    [self.sendButton setTitle:@"Sent" forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(sendInviteToCurrentPerson) forControlEvents:UIControlEventTouchUpInside];

    self.expandedContactInfoHeightConstraint.constant = 0;
}

- (void)updateWithInfoForPerson:(MAVEABPerson *)person {
    self.person = person;
    self.nameLabel.text = [person fullName];
    self.contactInfoLabel.text = [MAVEABPerson displayPhoneNumber:person.bestPhone];
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
    self.contactInfoLabel.text = nil;
    self.sendButton.hidden = YES;
}

- (void)sendInviteToCurrentPerson {
    if (self.delegateController) {
//        self.sendButton.enabled = NO;
        [self.delegateController sendInviteToPerson:self.person sendButton:self.sendButton];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
