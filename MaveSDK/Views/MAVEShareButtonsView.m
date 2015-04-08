//
//  MAVEShareIconsView.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/26/15.
//
//

#import "MAVEShareButtonsView.h"
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVESharer.h"
#import "MAVERemoteConfiguration.h"
#import "MAVEBuiltinUIElementUtils.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

// iOS 8.3 current beta turns off native twitter sharing, though isAvailableForService type still returns true
#define IS_IOS8_3 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.299)

CGFloat const MAVEShareIconsViewVerticalPadding = 10;
CGFloat const MAVEShareIconsSmallIconsEdgeSize = 22;

@implementation MAVEShareButtonsView

- (instancetype)initWithDelegate:(id<MAVEShareButtonsDelegate>)delegate iconColor:(UIColor *)iconColor iconFont:(UIFont *)iconFont backgroundColor:(UIColor *)backgroundColor useSmallIcons:(BOOL)useSmallIcons allowSMSShare:(BOOL)allowSMSShare {
    if (self = [super init]) {
        self.delegate = delegate;
        self.iconColor = iconColor;
        self.iconTextColor = iconColor;
        self.iconFont = iconFont;
        self.backgroundColor = backgroundColor;
        self.useSmallIcons = useSmallIcons;

        self.allowSMSShare = allowSMSShare;
    }
    return self;
}

- (void)layoutSubviews {
    [self layoutShareButtons];

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

- (void)layoutShareButtons {
    for (UIView *button in self.shareButtons) {
        if (![button isDescendantOfView:self]) {
            [self addSubview:button];
        }
    }
}

- (CGSize)intrinsicContentSize {
    CGFloat height = [self shareButtonSize].height + 2*MAVEShareIconsViewVerticalPadding;
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = [self shareButtonSize].height + 2*MAVEShareIconsViewVerticalPadding;
    CGFloat width = size.width;
    return CGSizeMake(width, height);
}

- (CGSize)shareButtonSize {
    if (!self.shareButtons) {
        [self setupShareButtons];
    }
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

- (void)setupShareButtons {
    self.shareButtons = [[NSMutableArray alloc] init];

    // Add share buttons for services
    UIButton *shareButton;
    if (self.allowSMSShare && [MFMessageComposeViewController canSendText]) {
        shareButton = [self smsShareButton];
        [self.shareButtons addObject:shareButton];
    }
    if ([MFMailComposeViewController canSendMail]) {
        shareButton = [self emailShareButton];
        [self.shareButtons addObject:shareButton];
    }

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        shareButton = [self facebookShareButton];
        [self.shareButtons addObject:shareButton];
    }

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && !IS_IOS8_3) {
        shareButton = [self twitterShareButton];
        [self.shareButtons addObject:shareButton];
    }

    shareButton = [self clipboardShareButton];
    [self.shareButtons addObject:shareButton];
}


# pragma mark - Share buttons by service
- (UIButton *)genericShareButtonWithIconNamed:(NSString*)imageName andLabelText:(NSString *)text {
    UIColor *labelColor = self.iconTextColor;
    UIFont *labelFont = self.iconFont;
    UIColor *iconColor = self.iconColor;

    UIImage *image = [MAVEBuiltinUIElementUtils imageNamed:imageName fromBundle:MAVEResourceBundleName];
    image = [MAVEBuiltinUIElementUtils tintWhitesInImage:image withColor:iconColor];

    CGFloat textToImagePadding;
    if (self.useSmallIcons) {
        // scale image and reduce padding from image to text
        CGSize smallSize = CGSizeMake(MAVEShareIconsSmallIconsEdgeSize,
                                  MAVEShareIconsSmallIconsEdgeSize);
        image = [MAVEBuiltinUIElementUtils imageWithImage:image scaledToSize:smallSize];
        textToImagePadding = 1;
    } else {
        textToImagePadding = 4;
    }

    MAVEUIButtonWithImageAndText *button = [[MAVEUIButtonWithImageAndText alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = labelFont;
    [button setTitleColor:labelColor forState:UIControlStateNormal];
    button.paddingBetweenImageAndText = textToImagePadding;
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
//    [button addTarget:self.delegate
//               action:@selector(emailClientSideShare)
//     forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self
               action:@selector(doEmailShare)
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
//    [button addTarget:self.delegate
//               action:@selector(clipboardShare)
//     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Share Actions

- (UIViewController *)presentingViewController {
    UIResponder *responder = self;
    while (![responder isKindOfClass:[UIViewController class]])
        responder = [responder nextResponder];
        if (!responder) {
            return nil;
        }
    return (UIViewController *)responder;
}

- (void)afterShareActions {
    [MAVESharer resetShareToken];
    if (self.dismissMaveTopLevelOnSuccessfulShare) {
        [[MaveSDK sharedInstance].invitePageChooser dismissOnSuccess:1];
    }
}

- (void)doClientSMSShare {
    UIViewController *vc = [MAVESharer composeClientSMSInviteToRecipientPhones:nil completionBlock:^(MFMessageComposeViewController *controller, MessageComposeResult composeResult) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (composeResult == MessageComposeResultSent) {
            [self afterShareActions];
        }
    }];
    [self.presentingViewController presentViewController:vc animated:YES completion:nil];
}

- (void)doEmailShare {
    UIViewController *vc = [MAVESharer composeClientEmailWithCompletionBlock:^(MFMailComposeViewController *controller, MFMailComposeResult result) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (result == MFMailComposeResultSent) {
            [self afterShareActions];
        }
    }];
    [self.presentingViewController presentViewController:vc animated:YES completion:nil];
}

- (void)doFacebookNativeiOSShare {
    UIViewController *vc = [MAVESharer composeFacebookNativeShareWithCompletionBlock:^(SLComposeViewController *controller, SLComposeViewControllerResult result) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (result == SLComposeViewControllerResultDone) {
            [self afterShareActions];
        }
    }];
    [self.presentingViewController presentViewController:vc animated:YES completion:nil];
}

- (void)doTwitterNativeiOSShare {
    UIViewController *vc = [MAVESharer composeTwitterNativeShareWithCompletionBlock:^(SLComposeViewController *controller, SLComposeViewControllerResult result) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (result == SLComposeViewControllerResultDone) {
            [self afterShareActions];
        }
    }];
    [self.presentingViewController presentViewController:vc animated:YES completion:nil];
}

- (void)doClipboardShare {
    [MAVESharer composePasteboardShare];
}

@end
