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
#import "MaveSDK_Internal.h"
#import "MAVEConstants.h"
#import "MAVEDisplayOptions.h"
#import "MAVEBuiltinUIElementUtils.h"

@implementation MAVECustomSharePageView

- (instancetype)initWithDelegate:(MAVECustomSharePageViewController *)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.shareButtons = [[NSMutableArray alloc] init];

        MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;
        MAVERemoteConfiguration *remoteConfig = [MaveSDK sharedInstance].remoteConfiguration;
        self.backgroundColor = opts.sharePageBackgroundColor;
        self.shareExplanationLabel = [[UILabel alloc] init];
        self.shareExplanationLabel.text = remoteConfig.customSharePage.explanationCopy;

        self.shareExplanationLabel.font = opts.sharePageExplanationFont;
        self.shareExplanationLabel.textColor = opts.sharePageExplanationTextColor;
        self.shareExplanationLabel.textAlignment = NSTextAlignmentCenter;
        self.shareExplanationLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.shareExplanationLabel.numberOfLines = 0;

        [self addSubview:self.shareExplanationLabel];


        // Add share buttons for services
        // TODO: test this logic
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
    CGSize totalFrameSize = self.frame.size;
    BOOL isInPortrait = totalFrameSize.width < totalFrameSize.height;

    CGFloat explanationLabelSideMargins = 25;
    CGFloat explanationLabelWidth = totalFrameSize.width - 2 * explanationLabelSideMargins;
    CGSize explanationLabelSize = [self.shareExplanationLabel sizeThatFits:CGSizeMake(explanationLabelWidth, FLT_MAX)];

    CGFloat explanationLabelX = (totalFrameSize.width - explanationLabelSize.width) / 2;
    // space between the explanation copy and row of share buttons

    // Layout content. Should be lower in landscape
    CGFloat explanationShareButtonMarginRatio;
    CGFloat explanationVerticalRatio;
    if (isInPortrait) {
        explanationVerticalRatio = 0.22;
        explanationShareButtonMarginRatio = 0.13;
    } else {
        explanationVerticalRatio = 0.30;
        explanationShareButtonMarginRatio = 0.20;
    }
    CGFloat explanationLabelY = round(totalFrameSize.height * explanationVerticalRatio);
    CGFloat explanationShareButtonMargin = round(totalFrameSize.height * explanationShareButtonMarginRatio);
    CGFloat shareButtonsY = explanationLabelY + explanationLabelSize.height + explanationShareButtonMargin;

    self.shareExplanationLabel.frame = CGRectMake(explanationLabelX,
                                                  explanationLabelY,
                                                  explanationLabelSize.width,
                                                  explanationLabelSize.height);

    [self layoutShareButtonsWithYCoordinate:shareButtonsY];
}

- (void)layoutShareButtonsWithYCoordinate:(CGFloat)shareButtonsYCoordinate {
    CGSize totalFrameSize = self.frame.size;

    CGSize shareButtonSize = [self shareButtonSize];
    CGFloat numShareButtons = [self.shareButtons count];
    if (shareButtonSize.width * [self.shareButtons count] > totalFrameSize.width) {
        // What to do? scale down share button size?
        // We won't get here for now but if there's a variable number of
        // share icons or something later we may want to cover this case
    }

    // Make in between button and outer margins all the same size
    CGFloat numberMargins = numShareButtons + 1;
//    CGFloat shareButtonsSize
    CGFloat combinedMarginWidth =  totalFrameSize.width - shareButtonSize.width * numShareButtons;
    CGFloat marginWidth = combinedMarginWidth / numberMargins;

    CGFloat coordX = marginWidth;
    for (UIButton *shareButton in self.shareButtons) {
        shareButton.frame = CGRectMake(coordX, shareButtonsYCoordinate, shareButtonSize.width, shareButtonSize.height);
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
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;
    UIColor *labelColor = opts.sharePageIconTextColor;
    UIFont *labelFont = opts.sharePageIconFont;
    UIColor *iconColor = opts.sharePageIconColor;

    UIImage *image = [MAVEBuiltinUIElementUtils imageNamed:imageName fromBundle:MAVEResourceBundleName];
    image = [MAVEBuiltinUIElementUtils tintWhitesInImage:image withColor:iconColor];

    MAVEUIButtonWithImageAndText *button = [[MAVEUIButtonWithImageAndText alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = labelFont;
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
