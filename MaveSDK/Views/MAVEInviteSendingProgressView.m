//
//  MAVEInviteMessageSendingView.m
//  Mave
//
//  Created by dannycosson on 10/17/14.
//
//

#import "Mave.h"
#import "MAVEInviteSendingProgressView.h"

@implementation MAVEInviteSendingProgressView

float const MAX_PROGRESS = 0.8;
float const SECS_TO_FILL_PROGRESS_BAR = 2.0;
float const PROGRESS_TIMER_INVERVAL = 0.1;
float const INCREMENT_PROGRESS_BAR_BY = MAX_PROGRESS / (SECS_TO_FILL_PROGRESS_BAR / PROGRESS_TIMER_INVERVAL);

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        MAVEDisplayOptions *displayOptions = [Mave sharedInstance].displayOptions;
        [self setBackgroundColor:displayOptions.bottomViewBackgroundColor];
        
        CGRect progressViewFrame = CGRectMake(0, 0, frame.size.width, 10);
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self.progressView setTintColor:displayOptions.sendButtonColor];
        [self.progressView setFrame:progressViewFrame];
        self.progressView.progress = 0.0;
        
        self.mainLabel = [[UILabel alloc] init];
        self.mainLabel.textColor = displayOptions.sendButtonColor;
        [self setMainLabelText:@"Sending..."];
        
        [self addSubview:self.progressView];
        [self addSubview:self.mainLabel];
    }
    return self;
}
                             
- (void)setMainLabelText:(NSString *)text {
    self.mainLabel.font = [UIFont systemFontOfSize:14.0];
    self.mainLabel.text = text;
    CGRect labelFrame = [self computeMainLabelFrame];
    [self.mainLabel setFrame:labelFrame];
    [self.mainLabel setNeedsDisplay];
}

- (void)completeSendingProgress {
    float currentProgress = self.progressView.progress;
    if (currentProgress < 1.0) {
        [self.progressView setProgress:1.0 animated:YES];
    }
    [self setMainLabelText:@"Sent!"];
    [self setNeedsDisplay];
}

// Starts filling out progress bar on a timer up to 80%, will get completed
// when the request returns
- (void)startTimedProgress {
    [NSTimer scheduledTimerWithTimeInterval:PROGRESS_TIMER_INVERVAL
                                     target:self
                                   selector:@selector(updateProgressViewFromTimer:)
                                   userInfo:@{}
                                    repeats:YES];
}

- (void)updateProgressViewFromTimer:(NSTimer *)timer {
    float currentProgress = self.progressView.progress;
    if (currentProgress >= MAX_PROGRESS) {
        if (timer.valid) {
            [timer invalidate];
        }
        return;
    }
    [self.progressView setProgress:currentProgress+INCREMENT_PROGRESS_BAR_BY animated:YES];
}

// Control the "Sending..." label
- (CGRect)computeMainLabelFrame {
    CGSize labelSize = [self.mainLabel.text
                        sizeWithAttributes:@{NSFontAttributeName: self.mainLabel.font}];
    labelSize.width = ceilf(labelSize.width);
    labelSize.height = ceilf(labelSize.height);
    float labelOffsetX = (self.frame.size.width - labelSize.width) / 2;
    float labelOffsetY = (self.frame.size.height - labelSize.height) / 2;
    return CGRectMake(labelOffsetX, labelOffsetY, labelSize.width, labelSize.height);
}

@end
