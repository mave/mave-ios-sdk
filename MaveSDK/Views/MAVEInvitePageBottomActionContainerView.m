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
        [self makeInviteMessageViewActive];

        [self addSubview:self.inviteMessageView];
        [self addSubview:self.sendingInProgressView];
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

- (CGFloat)heightForViewCurrentInviteSendMethodWithWidth:(CGFloat)width {
    return [self.inviteMessageView computeHeightWithWidth:width];
}

- (void)layoutSubviews {
    CGRect fullOwnFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.inviteMessageView.frame = fullOwnFrame;
    self.sendingInProgressView.frame = fullOwnFrame;
}

@end
