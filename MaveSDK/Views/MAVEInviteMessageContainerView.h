//
//  MAVEInviteMessageContainerView.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/16/14.
//
//

#import <UIKit/UIKit.h>
#import "MAVEInviteMessageView.h"
#import "MAVEInviteSendingProgressView.h"

@interface MAVEInviteMessageContainerView : UIView

@property (nonatomic, strong) MAVEInviteMessageView *inviteMessageView;
@property (nonatomic, strong) MAVEInviteSendingProgressView *sendingInProgressView;

- (void)makeInviteMessageViewActive;
- (void)makeSendingInProgressViewActive;

@end
