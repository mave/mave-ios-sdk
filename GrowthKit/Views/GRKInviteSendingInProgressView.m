//
//  GRKInviteMessageSendingView.m
//  GrowthKit
//
//  Created by dannycosson on 10/17/14.
//
//

#import "GrowthKit.h"
#import "GRKInviteSendingInProgressView.h"

@implementation GRKInviteSendingInProgressView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        GRKDisplayOptions *displayOptions = [GrowthKit sharedInstance].displayOptions;
        [self setBackgroundColor:displayOptions.bottomViewBackgroundColor];
        
        CGRect progressViewFrame = CGRectMake(0, 0, frame.size.width, 10);
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self.progressView setFrame:progressViewFrame];
        self.progressView.progress = 0.0;
        
        [self setMainLabelWithText:@"Sending..." inFrame:frame];
        
        [self addSubview:self.progressView];
        [self addSubview:self.mainLabel];
    }
    return self;
}

- (void)setMainLabelWithText:(NSString *)labelText inFrame:(CGRect)containingFrame {
    UIFont *labelFont = [UIFont systemFontOfSize:14.0];
    CGSize labelSize = [labelText sizeWithAttributes:@{NSFontAttributeName: labelFont}];
    labelSize.width = ceilf(labelSize.width);
    labelSize.height = ceilf(labelSize.height);
    float labelOffsetX = (containingFrame.size.width - labelSize.width) / 2;
    float labelOffsetY = (containingFrame.size.height - labelSize.height) / 2;
    
    CGRect frame = CGRectMake(labelOffsetX, labelOffsetY, labelSize.width, labelSize.height);
    self.mainLabel = [[UILabel alloc] initWithFrame:frame];
    self.mainLabel.font = labelFont;
    self.mainLabel.text = labelText;
}

@end
