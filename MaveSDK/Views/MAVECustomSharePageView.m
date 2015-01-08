//
//  MAVENativeSharePageView.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import "MAVECustomSharePageView.h"
#import "MaveSDK.h"
#import "MAVEUIButtonWithImageAndText.h"

@implementation MAVECustomSharePageView

- (instancetype)init {
    if (self = [super init]) {
        self.shareButtons = [[NSMutableArray alloc] init];

        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        self.shareExplanationLabel = [[UILabel alloc] init];
        self.shareExplanationLabel.text = @"Share YourApp with friends and you\neach get $20 when they purchase";
        self.shareExplanationLabel.font = [UIFont systemFontOfSize:15.0];
        self.shareExplanationLabel.textAlignment = NSTextAlignmentCenter;
        self.shareExplanationLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.shareExplanationLabel.numberOfLines = 0;

        [self addSubview:self.shareExplanationLabel];


        // Add share buttons for services
        UIButton *shareButton;
        shareButton = [self smsShareButton];
        [self.shareButtons addObject:shareButton];
        [self addSubview:shareButton];

        shareButton = [self emailShareButton];
        [self.shareButtons addObject:shareButton];
        [self addSubview:shareButton];

        shareButton = [self facebookShareButton];
        [self.shareButtons addObject:shareButton];
        [self addSubview:shareButton];

        shareButton = [self twitterShareButton];
        [self.shareButtons addObject:shareButton];
        [self addSubview:shareButton];

        shareButton = [self clipboardShareButton];
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
    CGFloat explanationLabelY = 125;
    self.shareExplanationLabel.frame = CGRectMake(explanationLabelX,
                                                  explanationLabelY,
                                                  explanationLabelSize.width,
                                                  explanationLabelSize.height);

    [self layoutShareButtons];
}

- (void)layoutShareButtons {
    // Assigns frames to the array of self.shareButtons to lay them out
    CGSize totalFrameSize = self.frame.size;
    // Vertically the row of share buttons should have their centers 40%
    // of the way down the screen
    CGFloat verticalCenterRatioDownPage = 0.44;
    CGSize shareButtonSize = [self shareButtonSize];
    CGFloat numShareButtons = [self.shareButtons count];
    if (shareButtonSize.width * [self.shareButtons count] > totalFrameSize.width) {
        // What to do? scale down share button size?
        // We won't get here for now but if there's a variable number of
        // share icons or something later we may want to cover this case
    }


    CGFloat coordYCenters = verticalCenterRatioDownPage * totalFrameSize.height;
    CGFloat coordY = coordYCenters - (shareButtonSize.height / 2);

    // Make in between button and outer margins all the same size
    CGFloat numberMargins = numShareButtons + 1;
    CGFloat combinedMarginWidth =  totalFrameSize.width - shareButtonSize.width * numShareButtons;
    CGFloat marginWidth = combinedMarginWidth / numberMargins;

    CGFloat coordX = marginWidth;
    for (UIButton *shareButton in self.shareButtons) {
        shareButton.frame = CGRectMake(coordX, coordY, shareButtonSize.width, shareButtonSize.height);
        NSLog(@"adding button with size: %@", NSStringFromCGSize(shareButton.frame.size));
        coordX += shareButtonSize.width + marginWidth;
    }
}

- (CGSize)shareButtonSize {
    // All share buttons should be same size so return the size of the first one
    // unless there are none then return 0
    if ([self.shareButtons count] == 0) {
        return CGSizeMake(0, 0);
    }
//    return ((UIButton *)[self.shareButtons objectAtIndex:0]).imageView.image.size;
    return CGSizeMake(50, 50);
}


# pragma mark - Share buttons by service
- (UIButton *)genericShareButtonWithIcon:(UIImage *)image text:(NSString *)text {
    UIButton *button = [[MAVEUIButtonWithImageAndText alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:11];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    return button;
}

- (UIButton *)smsShareButton {
    UIImage *buttonIcon = [UIImage imageNamed:@"SMS-icon.png"];
    UIButton *button = [self genericShareButtonWithIcon:buttonIcon
                                                   text:@"SMS"];
    [button addTarget:[MaveSDK sharedInstance].shareActions
               action:@selector(smsClientSideShare)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)emailShareButton {
    UIImage *buttonIcon = [UIImage imageNamed:@"SMS-icon.png"];
    UIButton *button = [self genericShareButtonWithIcon:buttonIcon
                                                   text:@"EMAIL"];
    return button;
}

- (UIButton *)facebookShareButton {
    UIImage *buttonIcon = [UIImage imageNamed:@"SMS-icon.png"];
    UIButton *button = [self genericShareButtonWithIcon:buttonIcon
                                                   text:@"SMS"];
    return button;
}

- (UIButton *)twitterShareButton {
    UIImage *buttonIcon = [UIImage imageNamed:@"SMS-icon.png"];
    UIButton *button = [self genericShareButtonWithIcon:buttonIcon
                                                   text:@"SMS"];
    return button;
}

- (UIButton *)clipboardShareButton {
    UIImage *buttonIcon = [UIImage imageNamed:@"SMS-icon.png"];
    UIButton *button = [self genericShareButtonWithIcon:buttonIcon
                                                   text:@"SMS"];
    return button;
}

@end
