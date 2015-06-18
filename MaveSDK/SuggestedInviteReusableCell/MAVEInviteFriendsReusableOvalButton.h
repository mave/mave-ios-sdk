//
//  MAVEInviteFriendsReusableOvalButton.h
//  MaveSDK
//
//  Created by Danny Cosson on 6/9/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVEInviteFriendsReusableOvalButton : UIButton

@property (nonatomic, strong) UIColor *textAndIconColor;
@property (nonatomic, strong) UIColor *customBackgroundColor;
@property (nonatomic, copy) NSString *inviteContext;

@property (nonatomic, strong) UIImage *untintedImage;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *customImageView;
@property (nonatomic, strong) UILabel *customLabel;

// Callback so the code using this button can get notified if it's pressed
@property (nonatomic, copy) void (^openedInvitePageBlock)(NSUInteger numberInvitesSent);

- (void)setHeight:(CGFloat)height;
- (void)presentInvitePageModally;

@end
