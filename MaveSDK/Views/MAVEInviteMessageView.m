//
//  MAVEInviteMessageView.m
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaveSDK.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEInviteMessageView.h"
#import "MAVEDisplayOptions.h"

NSString * const SEND_MEDIUM_INDICATOR = @"Individual SMS";

// Constant layout values
CGFloat const textViewOuterPaddingWidth = 10;
CGFloat const textViewOuterPaddingHeight = 10;
CGFloat const textViewButtonSpacingWidth = 10;
CGFloat const textViewSendMediumIndicatorSpacingHeight = 5;

@implementation MAVEInviteMessageView

- (MAVEInviteMessageView *)init {
    // Get global display customization options, any of the values could have been
    // overwritten by the client app
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;
    
    // Button attributes
    NSString *buttonTitle = displayOptions.sendButtonCopy;

    // Create own containing view
    if (self = [super init]) {
        self.backgroundColor = displayOptions.bottomViewBackgroundColor;

        // Use a view to simulate a border that's on just the top
        self.fakeTopBorder = [[UIView alloc] init];
        self.fakeTopBorder.backgroundColor = displayOptions.bottomViewBorderColor;
        
        // Create child views (button & textView) & set non-layout styling
        // They will get laid out by layoutSubviews
        self.textView = [[UITextView alloc] init];
        self.textView.delegate = self;
        self.textView.layer.borderColor=[displayOptions.bottomViewBorderColor CGColor];
        self.textView.layer.cornerRadius=8.0f;
        self.textView.layer.masksToBounds=YES;
        self.textView.layer.borderWidth= 0.5f;
        self.textView.text = [MaveSDK sharedInstance].defaultSMSMessageText;
        self.textView.font = displayOptions.messageFieldFont;
        self.textView.textColor = displayOptions.messageFieldTextColor;
        self.textView.backgroundColor = displayOptions.messageFieldBackgroundColor;
        self.textView.returnKeyType = UIReturnKeyDone;
        self.textView.scrollEnabled = NO;
                
        self.sendButton = [[UIButton alloc] init];
        [self.sendButton setTitleColor:displayOptions.sendButtonTextColor forState:UIControlStateNormal];
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
        [self addSubview:self.textView];
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
    [self computeSubviewFramesIn:self.frame.size
                   textViewFrame:&textFrame
                 sendButtonFrame:&buttonFrame
        sendMediumIndicatorFrame:&sendMediumIndicatorFrame];
    self.fakeTopBorder.frame = CGRectMake(0, 0, self.frame.size.width, 0.5f);
    self.textView.frame = textFrame;

    self.sendButton.frame = buttonFrame;
    self.sendMediumIndicator.frame = sendMediumIndicatorFrame;
}

// Helper functions for computing sizes
- (CGFloat)computeHeightWithWidth:(CGFloat)width {
    CGSize textViewSize = [self textViewSizeWithContainerWidth:width];
    return textViewSize.height + [self sendMediumIndicatorSize].height +
        textViewOuterPaddingHeight + 2*textViewSendMediumIndicatorSpacingHeight;
}

- (CGSize)textViewSizeWithContainerWidth:(CGFloat)containerWidth {
    CGFloat tfWidth = containerWidth - 2*textViewOuterPaddingWidth - textViewButtonSpacingWidth - [self sendButtonSize].width;
    CGFloat tfHeight = [self.textView sizeThatFits:CGSizeMake(tfWidth, FLT_MAX)].height;
    return CGSizeMake(tfWidth, tfHeight);
}

- (CGSize)sendMediumIndicatorSize {
    return [self.sendMediumIndicator.text
            sizeWithAttributes:@{NSFontAttributeName: self.sendMediumIndicator.font}];
}

- (CGSize)sendButtonSize {
    return [self.sendButton.titleLabel.text
            sizeWithAttributes:@{NSFontAttributeName: self.sendButton.titleLabel.font}];
}

- (void)computeSubviewFramesIn:(CGSize)containerSize
                 textViewFrame:(CGRect *)textViewFrame
               sendButtonFrame:(CGRect *)sendButtonFrame
      sendMediumIndicatorFrame:(CGRect *)sendMediumIndicatorFrame {
    // Sizes based on fonts
    CGSize smiSize = [self sendMediumIndicatorSize];
    CGSize buttonSize = [self sendButtonSize];

    // Text View (dynamically sized based on default message text)
    CGSize textViewSize = [self textViewSizeWithContainerWidth:containerSize.width];

    // Button
    CGFloat buttonOffsetX = containerSize.width - textViewOuterPaddingWidth - buttonSize.width;
    CGFloat buttonOffsetY = (containerSize.height - buttonSize.height) / 2;

    // Send medium indicator derived attributes
    CGFloat smiOffsetX = (containerSize.width - smiSize.width) / 2;
    CGFloat smiOffsetY = textViewOuterPaddingHeight + textViewSize.height + textViewSendMediumIndicatorSpacingHeight;

    // Set pointers to return multiple values
    *textViewFrame = CGRectMake(textViewOuterPaddingWidth, textViewOuterPaddingHeight, textViewSize.width, textViewSize.height);
    *sendButtonFrame = CGRectMake(buttonOffsetX, buttonOffsetY, buttonSize.width, buttonSize.height);
    *sendMediumIndicatorFrame = CGRectMake(smiOffsetX, smiOffsetY, smiSize.width, smiSize.height);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView endEditing:YES];
        return NO;
    }
    NSString *newText = [textView.text substringToIndex:range.location];
    newText = [newText stringByAppendingString:text];
    newText = [newText stringByAppendingString:[textView.text substringFromIndex:range.location + range.length]];

    // Set a reasonable limit on text length not to go over
    if ([newText length] >= 300) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.textViewContentChangingBlock) {
        self.textViewContentChangingBlock();
    }
}

@end
