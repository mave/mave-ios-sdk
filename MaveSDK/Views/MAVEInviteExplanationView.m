//
//  MAVEInviteCopyView.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/18/14.
//
//

#import "MAVEInviteExplanationView.h"
#import "MaveSDK.h"
#import "MaveSDK_Internal.h"

const CGFloat LABEL_MARGIN_X = 20;
const CGFloat LABEL_MARGIN_Y = 20;

@implementation MAVEInviteExplanationView

- (instancetype)init {
    if (self = [super init]) {
        [self setupInit];
    }
    return self;
}

- (void)setupInit {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    self.backgroundColor = displayOptions.inviteExplanationCellBackgroundColor;

    self.messageCopy = [[UILabel alloc] init];
    self.messageCopy.font = displayOptions.inviteExplanationFont;
    self.messageCopy.textColor = displayOptions.inviteExplanationTextColor;
    self.messageCopy.text = [MaveSDK sharedInstance].inviteExplanationCopy;;
    self.messageCopy.textAlignment = NSTextAlignmentCenter;
    self.messageCopy.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageCopy.numberOfLines = 0;

    [self addSubview:self.messageCopy];
}

// Dynamic layout
- (void)layoutSubviews {
    CGSize labelSize = [self messageCopyLabelSizeWithWidth:self.frame.size.width];
    self.messageCopy.frame = CGRectMake(LABEL_MARGIN_X, LABEL_MARGIN_Y - MAVESearchBarHeight, labelSize.width, labelSize.height);
}

- (CGFloat)computeHeightWithWidth:(CGFloat)width {
    CGFloat labelHeight = [self messageCopyLabelSizeWithWidth:width].height;
    return labelHeight + 2*LABEL_MARGIN_Y - MAVESearchBarHeight;
}

- (CGSize)messageCopyLabelSizeWithWidth:(CGFloat)width {
    CGFloat labelWidth = width - 2*LABEL_MARGIN_X;
    CGFloat labelHeight = [self.messageCopy sizeThatFits:CGSizeMake(width, FLT_MAX)].height;
    return CGSizeMake(labelWidth, labelHeight);
}

@end
