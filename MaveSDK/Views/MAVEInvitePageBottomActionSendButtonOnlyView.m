//
//  MAVEInvitePageBottomActionSendButtonOnlyView.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/5/15.
//
//

#import "MAVEInvitePageBottomActionSendButtonOnlyView.h"
#import "MaveSDK.h"

NSString * const NumberSelectedIndicatorFormat = @"Compose SMS to %@ people";

@implementation MAVEInvitePageBottomActionSendButtonOnlyView

- (instancetype)init {
    if (self = [super init]) {
        [self setupViewsWithSingletonObject:[MaveSDK sharedInstance]];

    }
    return self;
}

- (void)setupViewsWithSingletonObject:(MaveSDK *)mave {
    self.numberSelected = 0;
    self.backgroundColor = mave.displayOptions.bottomViewBackgroundColor;

    self.sendButton = [[UIButton alloc] init];
    [self.sendButton setTitleColor:mave.displayOptions.sendButtonTextColor
                          forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor grayColor]
                          forState:UIControlStateHighlighted];
    self.sendButton.titleLabel.font = mave.displayOptions.sendButtonFont;
    [self.sendButton setTitle:@"INVITE" forState: UIControlStateNormal];
    self.sendButton.enabled = YES;

    self.numberSelectedIndicator = [[UILabel alloc] init];
    self.numberSelectedIndicator.textColor = [[mave.displayOptions class] colorMediumGrey];
    self.numberSelectedIndicator.font = [UIFont systemFontOfSize:10];

    [self addSubview:self.sendButton];
    [self addSubview:self.numberSelectedIndicator];
}

- (void)layoutSubviews {
    CGSize buttonSize = [self.sendButton.titleLabel.text
                         sizeWithAttributes:@{NSFontAttributeName: self.sendButton.titleLabel.font}];
    buttonSize.width = ceil(buttonSize.width);
    buttonSize.height = ceil(buttonSize.height);

    CGFloat aboveButtonExtraPaddingY = 7;
    CGFloat buttonToLabelPaddingY = 2;

    self.numberSelectedIndicator.text = [NSString stringWithFormat:NumberSelectedIndicatorFormat, @(self.numberSelected)];
    CGSize numberSelectedSize = [self.numberSelectedIndicator.text
                                sizeWithAttributes:@{NSFontAttributeName: self.numberSelectedIndicator.font}];
    numberSelectedSize.width = ceil(numberSelectedSize.width);
    numberSelectedSize.height = ceil(numberSelectedSize.height);

    CGFloat buttonAndLabelHeight = buttonSize.height + buttonToLabelPaddingY + numberSelectedSize.height;
    CGFloat buttonY = (self.frame.size.height - buttonAndLabelHeight) / 2 + aboveButtonExtraPaddingY;
    self.sendButton.frame = CGRectMake((self.frame.size.width - buttonSize.width) / 2,
                                       buttonY,
                                       buttonSize.width, buttonSize.height);
    CGFloat numberSelectedY = self.sendButton.frame.origin.y + self.sendButton.frame.size.height + buttonToLabelPaddingY;
    self.numberSelectedIndicator.frame = CGRectMake((self.frame.size.width - numberSelectedSize.width) / 2,
                                                    numberSelectedY,
                                                    numberSelectedSize.width, numberSelectedSize.height);
}

- (CGFloat)heightOfSelf {
    return 70;
}

@end
