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

@property (strong, nonatomic) MAVEInviteMessageView *inviteMessageView;
@property (strong, nonatomic) MAVEInviteSendingProgressView *sendingInProgressView;

- (void)makeInviteMessageViewActive;
- (void)makeSendingInProgressViewActive;

@end
