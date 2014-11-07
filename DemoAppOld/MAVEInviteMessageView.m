//
//  MAVEInviteMessageView.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaveSDK.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEInviteMessageView.h"
#import "MAVEDisplayOptions.h"

@implementation MAVEInviteMessageView

- (MAVEInviteMessageView *)initCustomWithFrame:(CGRect)frame {
    // Get global display customization options, any of the values could have been
    // overwritten by the client app
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    // TextView Attributes
    UIColor *tfBgColor = [[UIColor alloc] initWithWhite:0.9 alpha:1.0];
    UIColor *tfBorderColor = [UIColor blackColor];
    
    // Button attributes
    NSString *buttonTitle = @"Send";
    float buttonTitleFontSize = 12;
    UIColor *buttonTitleTextColor = [UIColor blackColor];
    UIFont *buttonFont = [UIFont systemFontOfSize:buttonTitleFontSize];
    
    // Create own containing view
    self = [[MAVEInviteMessageView alloc] initWithFrame:frame];
    [self setBackgroundColor:displayOptions.bottomViewBackgroundColor];
    
    // Create child views (button & textView) & set non-layout styling
    // They will get laid out by layoutSubviews
    self.sendButton = [[UIButton alloc] init];
    self.textField = [[UITextView alloc] init];
    
    self.textField.layer.backgroundColor=[tfBgColor CGColor];
    self.textField.layer.borderColor=[tfBorderColor CGColor];
    self.textField.layer.cornerRadius=8.0f;
    self.textField.layer.masksToBounds=YES;
    self.textField.layer.borderWidth= 0.5f;
    [self.textField setText:@"I invest with Betterment and thought you would like it. Use my invite link to sign up"];
    
    self.sendButton.titleLabel.textColor = buttonTitleTextColor;
    self.sendButton.titleLabel.font = buttonFont;
    [self.sendButton setTitle:buttonTitle forState: UIControlStateNormal];
    
    [self addSubview:self.textField];
    [self addSubview:self.sendButton];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"Layout subviews@");
    CGRect textFrame, buttonFrame;
    [self computeFrameSizesWithContainingFrame:self.frame
                                    ButtonFont:self.sendButton.titleLabel.font
                                   buttonTitle:self.sendButton.titleLabel.text
                           createTextViewFrame:&textFrame
                               sendButtonFrame:&buttonFrame];
    [self.textField setFrame:textFrame];
    [self.sendButton setFrame:buttonFrame];
}

- (void)computeFrameSizesWithContainingFrame:(CGRect)containingFrame
                                  ButtonFont:(UIFont *)buttonFont
                                 buttonTitle:(NSString *)buttonTitle
                         createTextViewFrame:(CGRect *)textViewFrame
                             sendButtonFrame:(CGRect *)sendButtonFrame {
    // TextView
    float tfOuterPaddingWidth = 10;
    float tfOuterPaddingHeight = 10;
    float tfFieldButtonSpacingWidth = tfOuterPaddingWidth;

    // Button
    CGSize buttonSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName: buttonFont}];
    buttonSize.width = ceilf(buttonSize.width);
    buttonSize.height = ceilf(buttonSize.height);
    float buttonOffsetX = containingFrame.size.width - tfOuterPaddingWidth - buttonSize.width;
    float buttonOffsetY = (containingFrame.size.height - buttonSize.height) / 2;

    // TextField derived attributes
    float tfWidth = containingFrame.size.width - 2*tfOuterPaddingWidth - tfFieldButtonSpacingWidth - buttonSize.width;
    float tfHeight = containingFrame.size.height - 2*tfOuterPaddingHeight;

    // Set pointers to return multiple values
    *textViewFrame = CGRectMake(tfOuterPaddingWidth, tfOuterPaddingHeight, tfWidth, tfHeight);
    *sendButtonFrame = CGRectMake(buttonOffsetX, buttonOffsetY, buttonSize.width, buttonSize.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
