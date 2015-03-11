//
//  MAVEBottomActionContainerView.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/16/14.
//
//

#import <UIKit/UIKit.h>
#import "MAVERemoteConfigurationContactsInvitePage.h"
#import "MAVEInviteMessageView.h"
#import "MAVEInviteSendingProgressView.h"
#import "MAVEInvitePageBottomActionSendButtonOnlyView.h"

@interface MAVEInvitePageBottomActionContainerView : UIView

@property (nonatomic, assign) MAVESMSInviteSendMethod smsInviteSendMethod;
@property (nonatomic, strong) MAVEInviteMessageView *inviteMessageView;
@property (nonatomic, strong) MAVEInviteSendingProgressView *sendingInProgressView;
@property (nonatomic, strong) MAVEInvitePageBottomActionSendButtonOnlyView *clientSideBottomActionView;

- (instancetype)initWithSMSInviteSendMethod:(MAVESMSInviteSendMethod)smsInviteSendMethod;
- (void)makeInviteMessageViewActive;
- (void)makeSendingInProgressViewActive;

- (CGFloat)heightForViewWithWidth:(CGFloat)width;
- (void)updateNumberPeopleSelected:(NSUInteger)numberOfPeople;
- (void)addToSendButtonTarget:(id)target andAction:(SEL)action;

@end
