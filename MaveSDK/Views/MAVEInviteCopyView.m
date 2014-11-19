//
//  MAVEInviteCopyView.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/18/14.
//
//

#import "MAVEInviteCopyView.h"
#import "MaveSDK.h"

const CGFloat LABEL_MARGIN_X = 15;
const CGFloat LABEL_MARGIN_Y = 12;

@implementation MAVEInviteCopyView

- (instancetype)init {
    if (self = [super init]) {
        [self setupInit];
    }
    return self;
}

- (void)setupInit {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    self.backgroundColor = displayOptions.userExplanationCellBackgroundColor;

    self.messageCopy = [[UILabel alloc] init];
    self.messageCopy.font = displayOptions.userExplanationFont;
    self.messageCopy.textColor = displayOptions.userExplanationTextColor;
    self.messageCopy.text = @"Get $20 for each friend you invite, this is some longer text blah";
    self.messageCopy.textAlignment = NSTextAlignmentCenter;
    self.messageCopy.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageCopy.numberOfLines = 0;

    [self addSubview:self.messageCopy];
}

// Dynamic layout
- (void)layoutSubviews {
    CGSize labelSize = [self messageCopyLabelSizeWithWidth:self.frame.size.width];
    self.messageCopy.frame = CGRectMake(LABEL_MARGIN_X, LABEL_MARGIN_Y, labelSize.width, labelSize.height);
}

- (CGFloat)computeHeightWithWidth:(CGFloat)width {
    CGFloat labelHeight = [self messageCopyLabelSizeWithWidth:width].height;
    return labelHeight + 2*LABEL_MARGIN_Y;
}

- (CGSize)messageCopyLabelSizeWithWidth:(CGFloat)width {
    CGFloat labelWidth = width - 2*LABEL_MARGIN_X;
    CGFloat labelHeight = [self.messageCopy sizeThatFits:CGSizeMake(width, FLT_MAX)].height;
    return CGSizeMake(labelWidth, labelHeight);
}

@end
