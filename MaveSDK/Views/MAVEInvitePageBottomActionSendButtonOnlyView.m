//
//  MAVEInvitePageBottomActionSendButtonOnlyView.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/5/15.
//
//

#import "MAVEInvitePageBottomActionSendButtonOnlyView.h"
#import "MaveSDK.h"

@implementation MAVEInvitePageBottomActionSendButtonOnlyView

- (instancetype)init {
    if (self = [super init]) {
        self.sendButton = [[UIButton alloc] init];
        self.sendButton.titleLabel.text = @"SEND";
        self.numberSelectedIndicator = [[UILabel alloc] init];

        [self addSubview:self.sendButton];
        [self addSubview:self.numberSelectedIndicator];
        [self setupViewsWithSingletonObject:[MaveSDK sharedInstance]];
    }
    return self;
}

- (void)setupViewsWithSingletonObject:(MaveSDK *)mave {
    self.backgroundColor = [UIColor greenColor];
}

- (void)layoutSubviews {
    self.sendButton.frame = CGRectMake(50, 20, 100, 30);
}

- (CGFloat)heightOfSelf {
    return 70;
}

@end
