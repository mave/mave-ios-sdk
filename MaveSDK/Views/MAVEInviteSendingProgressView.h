//
//  MAVEInviteMessageSendingView.h
//  MaveSDK
//
//  Created by dannycosson on 10/17/14.
//
//

#import <UIKit/UIKit.h>

@interface MAVEInviteSendingProgressView : UIView

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic) CGFloat progressBarIncrementBy;

- (void)startTimedProgress;
- (void)updateProgressViewFromTimer:(NSTimer *)timer;
- (void)completeSendingProgress;

@end
