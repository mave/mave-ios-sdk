//
//  MAVEInvitePageBottomActionSendButtonOnlyView.h
//  MaveSDK
//
//  Created by Danny Cosson on 3/5/15.
//
//

#import <UIKit/UIKit.h>

@class MaveSDK;

@interface MAVEInvitePageBottomActionSendButtonOnlyView : UIView

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UILabel *numberSelectedIndicator;
@property (nonatomic, assign) NSUInteger numberSelected;

- (CGFloat)heightOfSelf;
- (void)setupViewsWithSingletonObject:(MaveSDK *)mave;

@end
