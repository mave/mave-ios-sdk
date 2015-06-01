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
    MAVEDisplayOptions *displayOpts = [MaveSDK sharedInstance].displayOptions;
    return [self initWithLabelText:labelText
                  sectionIsWaiting:sectionIsWaiting
                         textColor:displayOpts.contactSectionHeaderTextColor
                   backgroundColor:displayOpts.contactSectionHeaderBackgroundColor
                              font:displayOpts.contactSectionHeaderFont];
}

- (instancetype)initWithLabelText:(NSString *)labelText
                 sectionIsWaiting:(BOOL)sectionIsWaiting
                        textColor:(UIColor *)textColor
              backgroundColor:(UIColor *)backgroundColor
                             font:(UIFont *)font {
    if (self = [super init]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = labelText;
        self.titleLabel.textColor = textColor;
        self.titleLabel.font = font;
        self.backgroundColor = backgroundColor;

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
    }
}

- (void)stopWaiting {
    if (self.waitingDotsView) {
        self.waitingDotsView.hidden = YES;
    }
}

@end
