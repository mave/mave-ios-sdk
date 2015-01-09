//
//  MAVENativeSharePageView.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <Social/Social.h>
#import "MAVECustomSharePageView.h"
#import "MaveSDK.h"
#import "MAVEBuiltinUIElementUtils.h"

@implementation MAVECustomSharePageView

- (instancetype)initWithDelegate:(MAVEShareActions *)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
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
        if ([MFMessageComposeViewController canSendText]) {
            shareButton = [self smsShareButton];
            [self.shareButtons addObject:shareButton];
            [self addSubview:shareButton];
        }
        if ([MFMailComposeViewController canSendMail]) {
            shareButton = [self emailShareButton];
            [self.shareButtons addObject:shareButton];
            [self addSubview:shareButton];
        }

        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            shareButton = [self facebookShareButton];
            [self.shareButtons addObject:shareButton];
            [self addSubview:shareButton];
        }

        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            shareButton = [self twitterShareButton];
            [self.shareButtons addObject:shareButton];
            [self addSubview:shareButton];
        }

        shareButton = [self clipboardShareButton];
        [self.shareButtons addObject:shareButton];
        [self addSubview:shareButton];
    }
    return self;
}

- (void)layoutSubviews {
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
//    CGFloat shareButtonsSize
    CGFloat combinedMarginWidth =  totalFrameSize.width - shareButtonSize.width * numShareButtons;
    CGFloat marginWidth = combinedMarginWidth / numberMargins;

    CGFloat coordX = marginWidth;
    for (UIButton *shareButton in self.shareButtons) {
        shareButton.frame = CGRectMake(coordX, coordY, shareButtonSize.width, shareButtonSize.height);
        coordX += shareButtonSize.width + marginWidth;
    }
}

- (CGSize)shareButtonSize {
    // Make them all the same size, pick that size to be the smallest
    // that will fit the largest icon image and text of all the share buttons to display
    CGSize size = CGSizeMake(0, 0);
    CGFloat tmpHeight, tmpWidth;
    CGSize tmpLabelSize;
    for (MAVEUIButtonWithImageAndText *button in self.shareButtons) {
        // Figure out height of button, it's the sum of the image height, paddding btwn
        // image and title, and title height
        tmpLabelSize = [button.titleLabel.text
                        sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
        tmpHeight = button.imageView.image.size.height +
                    button.paddingBetweenImageAndText +
                    tmpLabelSize.height;
        if (tmpHeight > size.height) {
            size.height = tmpHeight;
        }

        // Figure out width of button, should be max(image width, text width)
        tmpWidth = MAX(button.imageView.image.size.width, tmpLabelSize.width);
        if (tmpWidth > size.width) {
            size.width = tmpWidth;
        }
    }
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}


# pragma mark - Share buttons by service
- (UIButton *)genericShareButtonWithIconNamed:(NSString*)imageName andLabelText:(NSString *)text {
    UIColor *labelColor = [UIColor colorWithWhite:0.5 alpha:1];
    UIColor *iconColor = [UIColor redColor];

    UIImage *image = [UIImage imageNamed:imageName];
    image = [MAVEBuiltinUIElementUtils tintWhitesInImage:image withColor:iconColor];

    MAVEUIButtonWithImageAndText *button = [[MAVEUIButtonWithImageAndText alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:10];
    [button setTitleColor:labelColor forState:UIControlStateNormal];
    button.paddingBetweenImageAndText = 4;
    return button;
}

- (UIButton *)smsShareButton {
    UIButton *button = [self genericShareButtonWithIconNamed:@"MAVEShareIconSMS.png"
                                                andLabelText:@"SMS"];
    [button addTarget:self.delegate
               action:@selector(smsClientSideShare)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)emailShareButton {
    UIButton *button = [self genericShareButtonWithIconNamed:@"MAVEShareIconEmail.png"
                                                andLabelText:@"EMAIL"];
    [button addTarget:self.delegate
               action:@selector(emailClientSideShare)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)facebookShareButton {
    UIButton *button = [self genericShareButtonWithIconNamed:@"MAVEShareIconFacebook.png"
                                                andLabelText:@"SHARE"];
    [button addTarget:self.delegate
               action:@selector(facebookiOSNativeShare)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)twitterShareButton {
    UIButton *button = [self genericShareButtonWithIconNamed:@"MAVEShareIconTwitter.png"
                                                andLabelText:@"TWEET"];
    [button addTarget:self.delegate
               action:@selector(twitteriOSNativeShare)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)clipboardShareButton {
    UIButton *button = [self genericShareButtonWithIconNamed:@"MAVEShareIconClipboard.png"
                                                andLabelText:@"COPY"];
    [button addTarget:self.delegate
               action:@selector(clipboardShare)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
