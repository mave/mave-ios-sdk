//
//  MAVEInviteMessageView.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAVEInviteMessageView : UIView <UITextViewDelegate>

@property UIView *fakeTopBorder;  // view to make a border on just one side
@property UIButton *sendButton;
@property UITextView *textField;
@property UILabel *sendMediumIndicator;  // e.g. "4 Individual SMS"

- (void)updateNumberPeopleSelected:(unsigned long)numberSelected;

@end