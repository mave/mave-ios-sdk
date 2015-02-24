//
//  MAVEInviteTableSectionHeaderView.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/19/15.
//
//

#import "MAVEInviteTableSectionHeaderView.h"
#import "MaveSDK.h"
#import "MAVEDisplayOptions.h"
#import "MAVEWaitingDotsImageView.h"

@implementation MAVEInviteTableSectionHeaderView

- (instancetype)initWithLabelText:(NSString *)labelText sectionIsWaiting:(BOOL)sectionIsWaiting {
    if (self = [super init]) {
        MAVEDisplayOptions *displayOpts = [MaveSDK sharedInstance].displayOptions;
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = labelText;
        self.titleLabel.textColor = displayOpts.contactSectionHeaderTextColor;
        self.titleLabel.font = displayOpts.contactSectionHeaderFont;

        self.backgroundColor = displayOpts.contactSectionHeaderBackgroundColor;

        [self addSubview:self.titleLabel];

        if (sectionIsWaiting) {
            self.waitingDotsView = [[MAVEWaitingDotsImageView alloc] init];
            [self addSubview: self.waitingDotsView];
        }

        [self initialLayoutOfSelfAndSubviews];
    }
    return self;
}

- (void)initialLayoutOfSelfAndSubviews {
    CGFloat sectionWidth = [UIScreen mainScreen].applicationFrame.size.width;
    CGFloat labelMarginY = 2.0;
    CGFloat labelOffsetX = 14.0;

    // layout
    CGSize labelSize = [self.titleLabel.text
                        sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    self.titleLabel.frame = CGRectMake(labelOffsetX,
                                       labelMarginY,
                                       labelSize.width,
                                       labelSize.height);

    CGFloat sectionHeight = labelMarginY * 2 + self.titleLabel.frame.size.height;

    // NB: section width gets ignored, always stretches to full width.
    // but we need the width for the pending dots
    self.frame = CGRectMake(0, 0, sectionWidth, sectionHeight);

    if (self.waitingDotsView) {
        CGFloat dotsHeight = sectionHeight / 3;
        CGFloat dotsWidth = dotsHeight * 4;
        self.waitingDotsView.frame = CGRectMake(
            sectionWidth - dotsWidth - 16, // push to the right
            (sectionHeight - dotsHeight) / 2,
            dotsWidth,
            dotsHeight);
        NSLog(@"waiting dots size: %@", NSStringFromCGSize(self.waitingDotsView.frame.size));
    }
}

- (void)stopWaiting {
    if (self.waitingDotsView) {
        self.waitingDotsView.hidden = YES;
    }
}

@end
