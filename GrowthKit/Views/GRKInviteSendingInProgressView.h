//
//  GRKInviteMessageSendingView.h
//  GrowthKit
//
//  Created by dannycosson on 10/17/14.
//
//

#import <UIKit/UIKit.h>

@interface GRKInviteSendingInProgressView : UIView

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic) float progressBarIncrementBy;

- (void)startTimedProgress;
- (void)updateProgressViewFromTimer:(NSTimer *)timer;
- (void)completeSendingProgress;

@end
