//
//  MAVEInviteMessageSendingView.m
//  MaveSDK
//
//  Created by dannycosson on 10/17/14.
//
//

#import "MaveSDK.h"
#import "MAVEInviteSendingProgressView.h"

@implementation MAVEInviteSendingProgressView

CGFloat const MAX_PROGRESS = 0.8;
CGFloat const SECS_TO_FILL_PROGRESS_BAR = 2.0;
CGFloat const PROGRESS_TIMER_INVERVAL = 0.1;
CGFloat const INCREMENT_PROGRESS_BAR_BY = MAX_PROGRESS / (SECS_TO_FILL_PROGRESS_BAR / PROGRESS_TIMER_INVERVAL);

- (instancetype)init {
    if (self = [super init]) {
        MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
        [self setBackgroundColor:displayOptions.bottomViewBackgroundColor];
    
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.tintColor = displayOptions.sendButtonTextColor;
        self.progressView.progress = 0.0;
        
        self.mainLabel = [[UILabel alloc] init];
        self.mainLabel.font = [UIFont systemFontOfSize:14.0];
        self.mainLabel.textColor = displayOptions.sendButtonTextColor;
        self.mainLabel.text = @"Sending";
        
        [self addSubview:self.progressView];
        [self addSubview:self.mainLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Compute and set progress view frame
    self.progressView.frame = CGRectMake(0, 0, self.frame.size.width, 10);
    
    // Compute and set main label frame
    CGSize labelSize = [self.mainLabel.text
                        sizeWithAttributes:@{NSFontAttributeName: self.mainLabel.font}];
    CGFloat labelOffsetX = (self.frame.size.width - labelSize.width) / 2;
    CGFloat labelOffsetY = (self.frame.size.height - labelSize.height) / 2;
    self.mainLabel.frame = CGRectMake(labelOffsetX,
                                      labelOffsetY,
                                      labelSize.width,
                                      labelSize.height);
}


#pragma mark - displaying progress

- (void)completeSendingProgress {
    CGFloat currentProgress = self.progressView.progress;
    if (currentProgress < 1.0) {
        [self.progressView setProgress:1.0 animated:YES];
    }
    self.mainLabel.text = @"Sent!";
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
    CGFloat currentProgress = self.progressView.progress;
    if (currentProgress >= MAX_PROGRESS) {
        if ([timer isValid]) {  // timer.valid is iOS8 only
            [timer invalidate];
        }
        return;
    }
    [self.progressView setProgress:currentProgress+INCREMENT_PROGRESS_BAR_BY animated:YES];
}

@end
