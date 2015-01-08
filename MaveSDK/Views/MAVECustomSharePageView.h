//
//  MAVENativeSharePageView.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVECustomSharePageView : UIView

@property (nonatomic, strong) UILabel *shareExplanationLabel;
@property (nonatomic, strong) NSMutableArray *shareButtons;

// Helpers
- (CGSize)shareButtonSize;  // all share buttons should be the same size
- (UIButton *)genericShareButton:(UIImage *)image;

- (UIButton *)smsShareButton;
- (UIButton *)emailShareButton;
- (UIButton *)facebookShareButton;
- (UIButton *)twitterShareButton;
- (UIButton *)clipboardShareButton;

@end
