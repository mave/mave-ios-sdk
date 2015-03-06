//
//  MAVEInvitePageBottomActionSendButtonOnlyView.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/5/15.
//
//

#import "MAVEInvitePageBottomActionSendButtonOnlyView.h"

@implementation MAVEInvitePageBottomActionSendButtonOnlyView

- (instancetype)init {
    if (self = [super init]) {
        self.sendButton = [[UIButton alloc] init];
        self.sendButton.titleLabel.text = @"SEND";
        self.numberSelectedIndicator = [[UILabel alloc] init];

        [self addSubview:self.sendButton];
        [self addSubview:self.numberSelectedIndicator];
    }
    return self;
}

- (void)layoutSubviews {
}

@end
