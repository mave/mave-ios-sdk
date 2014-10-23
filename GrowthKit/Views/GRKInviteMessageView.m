//
//  GRKInviteMessageView.m
//  GrowthKitDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowthKit.h"
#import "GRKInvitePageViewController.h"
#import "GRKInviteMessageView.h"
#import "GRKDisplayOptions.h"

@implementation GRKInviteMessageView

- (GRKInviteMessageView *)initWithFrame:(CGRect)frame {
    // Get global display customization options, any of the values could have been
    // overwritten by the client app
    GRKDisplayOptions *displayOptions = [GrowthKit sharedInstance].displayOptions;
    
    // Button attributes
    NSString *buttonTitle = @"Send";
    float buttonTitleFontSize = 12;
    UIFont *buttonFont = [UIFont systemFontOfSize:buttonTitleFontSize];
    
    // Create own containing view
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = displayOptions.bottomViewBackgroundColor;

        // Use a view to simulate a border that's on just the top
        UIView *fakeTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5f)];
        fakeTopBorder.backgroundColor = displayOptions.borderColor;
        
        // Create child views (button & textView) & set non-layout styling
        // They will get laid out by layoutSubviews
        self.sendButton = [[UIButton alloc] init];
        self.textField = [[UITextView alloc] init];
        
        self.textField.delegate = self;
        self.textField.layer.backgroundColor=[[GRKDisplayOptions colorWhite] CGColor];
        self.textField.layer.borderColor=[displayOptions.borderColor CGColor];
        self.textField.layer.cornerRadius=8.0f;
        self.textField.layer.masksToBounds=YES;
        self.textField.layer.borderWidth= 0.5f;
        [self.textField setText:@"Use my invite link to sign up!"];
        [self.textField setReturnKeyType:UIReturnKeyDone];
        
        [self.sendButton setTitleColor:displayOptions.tintColor forState:UIControlStateNormal];
        self.sendButton.titleLabel.font = buttonFont;
        [self.sendButton setTitle:buttonTitle forState: UIControlStateNormal];
        
        [self addSubview:fakeTopBorder];
        [self addSubview:self.textField];
        [self addSubview:self.sendButton];
    
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
