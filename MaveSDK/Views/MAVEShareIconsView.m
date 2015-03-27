//
//  MAVEShareIconsView.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/26/15.
//
//

#import "MAVEShareIconsView.h"
#import "MAVEConstants.h"
#import "MAVERemoteConfiguration.h"
#import "MAVEBuiltinUIElementUtils.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

CGFloat const MAVEShareIconsViewVerticalPadding = 10;


@implementation MAVEShareIconsView

- (instancetype)initWithDelegate:(id<MAVESharePageDelegate>)delegate iconColor:(UIColor *)iconColor iconFont:(UIFont *)iconFont backgroundColor:(UIColor *)backgroundColor {
    if (self = [super init]) {
        self.delegate = delegate;
        self.iconColor = iconColor;
        self.iconTextColor = iconColor;
        self.iconFont = iconFont;
        self.backgroundColor = backgroundColor;

        self.allowIncludeSMSIcon = YES;
    }
    return self;
}

- (void)setupShareButtons {
    self.shareButtons = [[NSMutableArray alloc] init];

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

- (void)layoutSubviews {
    if (!self.shareButtons) {
        [self setupShareButtons];
    }

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
    CGFloat coordY = MAVEShareIconsViewVerticalPadding;
    for (UIButton *shareButton in self.shareButtons) {
        shareButton.frame = CGRectMake(coordX, coordY, shareButtonSize.width, shareButtonSize.height);
        coordX += shareButtonSize.width + marginWidth;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = [self shareButtonSize].height + 2*MAVEShareIconsViewVerticalPadding;
    CGFloat width = size.width;
    return CGSizeMake(width, height);
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
    UIColor *labelColor = self.iconTextColor;
    UIFont *labelFont = self.iconFont;
    UIColor *iconColor = self.iconColor;

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
