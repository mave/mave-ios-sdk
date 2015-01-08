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
        self.shareButtons = [[NSMutableArray alloc] init];

        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        self.shareExplanationLabel = [[UILabel alloc] init];
        self.shareExplanationLabel.text = @"Hey, try this app";
        self.shareExplanationLabel.font = [UIFont systemFontOfSize:15.0];

        [self addSubview:self.shareExplanationLabel];


        UIButton *shareButton;
        shareButton = [self smsInviteButton];
        [self.shareButtons addObject:shareButton];
        [self addSubview:shareButton];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize totalSize = self.frame.size;

    CGSize explanationLabelSize = [self.shareExplanationLabel.text
        sizeWithAttributes:@{NSFontAttributeName: self.shareExplanationLabel.font}];
    CGFloat explanationLabelX = (self.frame.size.width - explanationLabelSize.width) / 2;
    CGFloat explanationLabelY = 120;
    self.shareExplanationLabel.frame = CGRectMake(explanationLabelX,
                                                  explanationLabelY,
                                                  explanationLabelSize.width,
                                                  explanationLabelSize.height);

    UIButton *button = [self.shareButtons objectAtIndex:0];
    NSLog(@"button size: %@", NSStringFromCGSize(button.imageView.image.size));
    NSLog(@"frame size: %@", NSStringFromCGSize(self.frame.size));
    NSLog(@"screen size: %@", NSStringFromCGSize([UIScreen mainScreen].bounds.size));
    button.frame = CGRectMake(20, 150, 30, 30);
}

- (void)layoutShareButtons {
    // Assigns frames to the array of self.shareButtons to lay them out
    CGSize totalFrameSize = self.frame.size;
    // Vertically the row of share buttons should have their centers 40%
    // of the way down the screen
    CGFloat verticalCenterRatioDownPage = 0.40;

    CGFloat coordYCenters = verticalCenterRatioDownPage * totalFrameSize.height;
    CGFloat coordY = coordYCenters - (self.shareButtonSize.height / 2);

    // Make in between button and outer margins all the same size
    CGFloat numberMargins = [self.shareButtons count] + 1;



}

- (CGSize)shareButtonSize {
    // All share buttons should be same size so return the size of the first one
    // unless there are none then return 0
    if ([self.shareButtons count] == 0) {
        return CGSizeMake(0, 0);
    }
    return ((UIButton *)[self.shareButtons objectAtIndex:0]).imageView.image.size;
}

- (UIButton *)smsInviteButton {
    UIButton *button = [[UIButton alloc] init];
    UIImage *image = [UIImage imageNamed:@"SMS-icon.png"];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateSelected];
    return button;
}

@end
