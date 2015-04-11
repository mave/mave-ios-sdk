//
//  MAVEShareIconsView.h
//  MaveSDK
//
//  Created by Danny Cosson on 3/26/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVEShareButtonsView : UIView

@property (nonatomic, strong) NSMutableArray *shareButtons;

@property (nonatomic, strong) UIColor *iconColor;
@property (nonatomic, strong) UIColor *iconTextColor;
@property (nonatomic, strong) UIFont *iconFont;
@property (nonatomic, assign) BOOL useSmallIcons;

@property (nonatomic, assign) BOOL allowSMSShare;

@property (nonatomic, assign) BOOL dismissMaveTopLevelOnSuccessfulShare;

// Helpers
- (CGSize)shareButtonSize;  // all share buttons should be the same size
- (UIButton *)genericShareButtonWithIconNamed:(NSString *)imageName
                                 andLabelText:(NSString *)text;

- (UIButton *)smsShareButton;
- (UIButton *)emailShareButton;
- (UIButton *)facebookShareButton;
- (UIButton *)twitterShareButton;
- (UIButton *)clipboardShareButton;

- (void)afterShareActions;
- (void)doClientSMSShare;
- (void)doClientEmailShare;
- (void)doFacebookNativeiOSShare;
- (void)doTwitterNativeiOSShare;
- (void)doClipboardShare;

@end
