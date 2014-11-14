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

NSString * const SEND_MEDIUM_INDICATOR = @"Individual SMS";

@implementation MAVEInviteMessageView

- (MAVEInviteMessageView *)initWithFrame:(CGRect)frame {
    // Get global display customization options, any of the values could have been
    // overwritten by the client app
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
    
    // Button attributes
    NSString *buttonTitle = @"Send";

    // Create own containing view
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = displayOptions.bottomViewBackgroundColor;

        // Use a view to simulate a border that's on just the top
        self.fakeTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5f)];
        self.fakeTopBorder.backgroundColor = displayOptions.bottomViewBorderColor;
        
        // Create child views (button & textView) & set non-layout styling
        // They will get laid out by layoutSubviews
        self.textField = [[UITextView alloc] init];
        self.textField.delegate = self;
        self.textField.layer.backgroundColor=[[MAVEDisplayOptions colorWhite] CGColor];
        self.textField.layer.borderColor=[displayOptions.bottomViewBorderColor CGColor];
        self.textField.layer.cornerRadius=8.0f;
        self.textField.layer.masksToBounds=YES;
        self.textField.layer.borderWidth= 0.5f;
        self.textField.text = [MaveSDK sharedInstance].defaultSMSMessageText;
        self.textField.font = [UIFont systemFontOfSize:16.0];
        self.textField.returnKeyType = UIReturnKeyDone;
        
        self.sendButton = [[UIButton alloc] init];
        [self.sendButton setTitleColor:displayOptions.sendButtonColor forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[MAVEDisplayOptions colorMediumGrey] forState:UIControlStateDisabled];
        self.sendButton.titleLabel.font = displayOptions.sendButtonFont;
        [self.sendButton setTitle:buttonTitle forState: UIControlStateNormal];
        [self.sendButton setTitle:buttonTitle forState:UIControlStateDisabled];
        self.sendButton.enabled = NO;
        
        
        self.sendMediumIndicator = [[UILabel alloc] init];
        self.sendMediumIndicator.font = displayOptions.contactDetailsFont;
        self.sendMediumIndicator.textColor = [MAVEDisplayOptions colorMediumGrey];
        self.sendMediumIndicator.text = SEND_MEDIUM_INDICATOR;
        
        [self addSubview:self.fakeTopBorder];
        [self addSubview:self.textField];
        [self addSubview:self.sendButton];
        [self addSubview:self.sendMediumIndicator];
    }
    return self;
}

- (void)updateNumberPeopleSelected:(unsigned long)numberSelected {
    NSString *copy = @""; BOOL buttonEnabled = NO;
    if (numberSelected > 0) {
        copy = [NSString stringWithFormat:@"%lu ", numberSelected];
        buttonEnabled = YES;
    }
    copy = [copy stringByAppendingString:SEND_MEDIUM_INDICATOR];
    self.sendMediumIndicator.text = copy;
    self.sendButton.enabled = buttonEnabled;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect textFrame, buttonFrame, sendMediumIndicatorFrame;
    [self computeFrameSizesWithContainingFrame:self.frame
                                    ButtonFont:self.sendButton.titleLabel.font
                                   buttonTitle:self.sendButton.titleLabel.text
                       sendMediumIndicatorFont:self.sendMediumIndicator.font
                      sendMediumIndicatorTitle:self.sendMediumIndicator.text
                           createTextViewFrame:&textFrame
                               sendButtonFrame:&buttonFrame
                      sendMediumIndicatorFrame:&sendMediumIndicatorFrame];
    [self.textField setFrame:textFrame];
    [self.sendButton setFrame:buttonFrame];
    [self.sendMediumIndicator setFrame:sendMediumIndicatorFrame];
}

- (void)computeFrameSizesWithContainingFrame:(CGRect)containingFrame
                                  ButtonFont:(UIFont *)buttonFont
                                 buttonTitle:(NSString *)buttonTitle
                     sendMediumIndicatorFont:(UIFont *)sendMediumIndicatorFont
                    sendMediumIndicatorTitle:(NSString *)sendMediumIndicatorTitle
                         createTextViewFrame:(CGRect *)textViewFrame
                             sendButtonFrame:(CGRect *)sendButtonFrame
                    sendMediumIndicatorFrame:(CGRect *)sendMediumIndicatorFrame {
    // TextView
    float tfOuterPaddingWidth = 10;
    float tfOuterPaddingHeight = 10;
    float tfSmiSpacingHeight = 5;
    float tfFieldButtonSpacingWidth = tfOuterPaddingWidth;

    // Button
    CGSize buttonSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName: buttonFont}];
    buttonSize.width = ceilf(buttonSize.width);
    buttonSize.height = ceilf(buttonSize.height);
    float buttonOffsetX = containingFrame.size.width - tfOuterPaddingWidth - buttonSize.width;
    float buttonOffsetY = (containingFrame.size.height - buttonSize.height) / 2;
    
    // Send medium indicator
    CGSize smiSize = [sendMediumIndicatorTitle sizeWithAttributes:@{NSFontAttributeName: sendMediumIndicatorFont}];
    smiSize.width = ceilf(smiSize.width);
    smiSize.height = ceilf(smiSize.height);

    // TextField derived attributes
    float tfWidth = containingFrame.size.width - 2*tfOuterPaddingWidth - tfFieldButtonSpacingWidth - buttonSize.width;
    float tfHeight = containingFrame.size.height - tfOuterPaddingHeight - 2*tfSmiSpacingHeight - smiSize.height;
    
    // Send medium indicator derived attributes
    float smiOffsetX = (containingFrame.size.width - smiSize.width) / 2;
    float smiOffsetY = tfOuterPaddingHeight + tfHeight + tfSmiSpacingHeight;

    // Set pointers to return multiple values
    *textViewFrame = CGRectMake(tfOuterPaddingWidth, tfOuterPaddingHeight, tfWidth, tfHeight);
    *sendButtonFrame = CGRectMake(buttonOffsetX, buttonOffsetY, buttonSize.width, buttonSize.height);
    *sendMediumIndicatorFrame = CGRectMake(smiOffsetX, smiOffsetY, smiSize.width, smiSize.height);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
