//
//  MAVEInviteMessageView.h
//  MaveSDKDevApp
//
//  Created by dannycosson on 10/2/14.
//  Copyright (c) 2014 Growthkit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAVEInviteMessageView : UIView

@property UIButton *sendButton;
@property UITextView *textField;

- (MAVEInviteMessageView *)initCustomWithFrame:(CGRect)frame;

@end
