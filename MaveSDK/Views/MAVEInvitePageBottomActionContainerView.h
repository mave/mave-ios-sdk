//
//  MAVEBottomActionContainerView.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/16/14.
//
//

#import <UIKit/UIKit.h>
#import "MAVEInviteMessageView.h"
#import "MAVEInviteSendingProgressView.h"
#import "MAVEInvitePageBottomActionSendButtonOnlyView.h"

typedef NS_ENUM(NSInteger, MAVESMSInviteSendMethod) {
    MAVESMSInviteSendMethodServerSide,
    MAVESMSInviteSendMethodClientSideGroup
};

@interface MAVEInvitePageBottomActionContainerView : UIView

@property (nonatomic, assign) MAVESMSInviteSendMethod smsInviteSendMethod;
@property (nonatomic, strong) MAVEInviteMessageView *inviteMessageView;
@property (nonatomic, strong) MAVEInviteSendingProgressView *sendingInProgressView;
@property (nonatomic, strong) MAVEInvitePageBottomActionSendButtonOnlyView *clientSideBottomActionView;

- (instancetype)initWithSMSInviteSendMethod:(MAVESMSInviteSendMethod)smsInviteSendMethod;
- (void)makeInviteMessageViewActive;
- (void)makeSendingInProgressViewActive;

- (CGFloat)heightForViewWithWidth:(CGFloat)width;
- (void)updateNumberPeopleSelected:(uint64_t)numberOfPeople;
- (void)addToSendButtonTarget:(id)target andAction:(SEL)action;

@end
