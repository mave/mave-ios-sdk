//
//  MAVEContactsInvitePageInlineSendButton.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/13/15.
//
//

#import "MAVEContactsInvitePageInlineSendButton.h"
#import "MaveSDK.h"

@implementation MAVEContactsInvitePageInlineSendButton

- (instancetype)init {
    if ((self = [[self class] buttonWithType:UIButtonTypeCustom])) {
        [self doInitialSetup];
    }
    return self;
}

- (void) doInitialSetup {
    self.sendingStatusSpinner = [[MAVESpinnerImageView alloc] initWithFrame:CGRectMake(10, 7, 18, 18)];
    [self.sendingStatusSpinner stopAnimating];

    self.sendActionCopy = @"Send";
    self.sentStateCopy = @"Sent";

    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;

    self.titleLabel.font = opts.contactInlineSendButtonFont;
    [self setTitle:self.sendActionCopy forState:UIControlStateNormal];
    [self setTitleColor:opts.contactInlineSendButtonTextColor forState:UIControlStateNormal];

    [self setTitle:self.sentStateCopy forState:UIControlStateDisabled];
    [self setTitleColor:opts.contactInlineSendButtonDisabledTextColor forState:UIControlStateDisabled];
}

- (void)setStatusUnsent {
    self.enabled = YES;
    [self.sendingStatusSpinner removeFromSuperview];
    [self.sendingStatusSpinner stopAnimating];
}

- (void)setStatusSending {
    [self setTitle:@"    " forState:UIControlStateDisabled];
    self.enabled = NO;
    [self addSubview:self.sendingStatusSpinner];
    [self.sendingStatusSpinner startAnimating];
}

- (void)setStatusSent {
    [self setTitle:self.sentStateCopy forState:UIControlStateDisabled];
    self.enabled = NO;
    [self.sendingStatusSpinner removeFromSuperview];
    [self.sendingStatusSpinner stopAnimating];
}



@end
