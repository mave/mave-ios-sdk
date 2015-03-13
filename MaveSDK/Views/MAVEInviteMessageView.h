//
//  MAVEInviteMessageView.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2015 Mave Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAVEInviteMessageView : UIView <UITextViewDelegate>

@property UIView *fakeTopBorder;  // view to make a border on just top side
@property UIButton *sendButton;
@property UITextView *textView;
@property UILabel *sendMediumIndicator;  // e.g. "4 Individual SMS"

@property (nonatomic, copy) void (^textViewContentChangingBlock)();

- (CGFloat)computeHeightWithWidth:(CGFloat)width;
- (void)updateNumberPeopleSelected:(unsigned long)numberSelected;

@end
