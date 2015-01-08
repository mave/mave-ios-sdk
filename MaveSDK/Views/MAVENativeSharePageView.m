//
//  MAVENativeSharePageView.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import "MAVENativeSharePageView.h"

@implementation MAVENativeSharePageView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        self.shareExplanationLabel = [[UILabel alloc] init];
        self.shareExplanationLabel.text = @"Hey, try this app";
        self.shareExplanationLabel.font = [UIFont systemFontOfSize:15.0];

        [self addSubview:self.shareExplanationLabel];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize explanationLabelSize = [self.shareExplanationLabel.text
        sizeWithAttributes:@{NSFontAttributeName: self.shareExplanationLabel.font}];
    CGFloat explanationLabelX = (self.frame.size.width - explanationLabelSize.width) / 2;
    CGFloat explanationLabelY = 120;
    self.shareExplanationLabel.frame = CGRectMake(explanationLabelX,
                                                  explanationLabelY,
                                                  explanationLabelSize.width,
                                                  explanationLabelSize.height);

}

@end
