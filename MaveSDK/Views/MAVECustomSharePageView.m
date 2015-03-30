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
    if (self = [super init]) {
        self.delegate = delegate;
        [self doInitialSetup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
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

    self.shareIconsView = [[MAVEShareButtonsView alloc] initWithDelegate:self.delegate iconColor:opts.sharePageIconColor iconFont:opts.sharePageIconFont backgroundColor:[UIColor clearColor] useSmallIcons:NO allowSMSShare:YES];
    [self addSubview:self.shareIconsView];
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

    CGSize shareIconsSize = [self.shareIconsView sizeThatFits:
                             CGSizeMake(totalFrameSize.width, CGFLOAT_MAX)];
    self.shareIconsView.frame = CGRectMake(0, shareButtonsY, shareIconsSize.width, shareIconsSize.height);
}
@end
