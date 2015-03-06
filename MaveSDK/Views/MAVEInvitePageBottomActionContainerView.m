//
//  MAVEBottomActionContainerView.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/16/14.
//
//

#import "MAVEInvitePageBottomActionContainerView.h"

@implementation MAVEInvitePageBottomActionContainerView

- (instancetype)initWithSMSInviteSendMethod:(MAVESMSInviteSendMethod)smsInviteSendMethod {
    self = [super init];
    if (self) {
        self.smsInviteSendMethod = smsInviteSendMethod;
        self.inviteMessageView = [[MAVEInviteMessageView alloc] init];
        self.sendingInProgressView = [[MAVEInviteSendingProgressView alloc] init];
        self.clientSideBottomActionView = [[MAVEInvitePageBottomActionSendButtonOnlyView alloc] init];

        if (self.smsInviteSendMethod == MAVESMSInviteSendMethodServerSide) {

            [self makeInviteMessageViewActive];

            [self addSubview:self.inviteMessageView];
            [self addSubview:self.sendingInProgressView];
        } else {
            [self addSubview:self.clientSideBottomActionView];
        }
    }
    return self;
}

- (void)addToSendButtonTarget:(id)target andAction:(SEL)action {
    switch (self.smsInviteSendMethod) {
        case MAVESMSInviteSendMethodServerSide: {
            [self.inviteMessageView.sendButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case MAVESMSInviteSendMethodClientSideGroup: {
            [self.clientSideBottomActionView.sendButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            break;
        }

        default:
            break;
    }
}

- (void)updateNumberPeopleSelected:(uint64_t)numberOfPeople {
    switch (self.smsInviteSendMethod) {
        case MAVESMSInviteSendMethodServerSide: {
            [self.inviteMessageView updateNumberPeopleSelected:numberOfPeople];
        }
        case MAVESMSInviteSendMethodClientSideGroup: {
            self.clientSideBottomActionView.numberSelected = numberOfPeople;
            [self.clientSideBottomActionView setNeedsLayout];
            break;
        }
        default: {
            break;
        }
    }
}

// Switch the active view when using server side SMS method
- (void)makeInviteMessageViewActive {
    self.inviteMessageView.hidden = NO;
    self.sendingInProgressView.hidden = YES;
}

- (void)makeSendingInProgressViewActive {
    self.inviteMessageView.hidden = YES;
    self.sendingInProgressView.hidden = NO;
    [self.sendingInProgressView startTimedProgress];
}

- (CGFloat)heightForViewWithWidth:(CGFloat)width {
    if (self.smsInviteSendMethod == MAVESMSInviteSendMethodServerSide) {
        return [self.inviteMessageView computeHeightWithWidth:width];
    } else {
        return [self.clientSideBottomActionView heightOfSelf];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect fullOwnFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.inviteMessageView.frame = fullOwnFrame;
    self.sendingInProgressView.frame = fullOwnFrame;
    self.clientSideBottomActionView.frame = fullOwnFrame;
}

@end
