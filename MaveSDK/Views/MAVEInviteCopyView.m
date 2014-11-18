//
//  MAVEInviteCopyView.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/18/14.
//
//

#import "MAVEInviteCopyView.h"

const CGFloat LABEL_MARGIN_X = 10;
const CGFloat LABEL_MARGIN_Y = 10;

@implementation MAVEInviteCopyView

- (instancetype)init {
    if (self = [super init]) {
        [self setupInit];
    }
    return self;
}

- (void)setupInit {
    self.backgroundColor = [UIColor whiteColor];

    self.messageCopy = [[UILabel alloc] init];
    self.messageCopy.font = [UIFont systemFontOfSize:14];
    self.messageCopy.textColor = [UIColor blackColor];
    self.messageCopy.text = @"Get $20 for each friend you invite, this is some longer text blah";
    self.messageCopy.textAlignment = NSTextAlignmentCenter;
    self.messageCopy.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageCopy.numberOfLines = 0;

    [self addSubview:self.messageCopy];
}

// Dynamic layout
- (void)layoutSubviews {
    NSLog(@"in layout subvies");
    CGFloat messageCopyXMargin = 20;
    CGFloat messageCopyWidth = self.frame.size.width - 2*messageCopyXMargin;
    self.messageCopy.frame = CGRectMake(messageCopyXMargin, 0, messageCopyWidth, 50);
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
