//
//  MAVEShareIconsView.h
//  MaveSDK
//
//  Created by Danny Cosson on 3/26/15.
//
//

#import <UIKit/UIKit.h>

@protocol MAVESharePageDelegate

- (void)smsClientSideShare;
- (void)emailClientSideShare;

@end

@interface MAVEShareIconsView : UIView

@property (nonatomic, strong) id<MAVESharePageDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *shareButtons;

- (instancetype)initWithDelegate:(id<MAVESharePageDelegate>)delegate;

// Helpers
- (CGSize)shareButtonSize;  // all share buttons should be the same size
- (UIButton *)genericShareButtonWithIconNamed:(NSString *)imageName
                                 andLabelText:(NSString *)text;

- (UIButton *)smsShareButton;
- (UIButton *)emailShareButton;
- (UIButton *)facebookShareButton;
- (UIButton *)twitterShareButton;
- (UIButton *)clipboardShareButton;

@end
