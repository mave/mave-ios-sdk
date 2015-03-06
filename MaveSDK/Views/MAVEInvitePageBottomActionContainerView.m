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
    CGRect fullOwnFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.inviteMessageView.frame = fullOwnFrame;
    self.sendingInProgressView.frame = fullOwnFrame;
    self.clientSideBottomActionView.frame = fullOwnFrame;
}

@end
