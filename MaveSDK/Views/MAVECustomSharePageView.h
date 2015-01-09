//
//  MAVENativeSharePageView.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEShareActions.h"

@interface MAVECustomSharePageView : UIView

@property (nonatomic, weak) MAVEShareActions *delegate;
@property (nonatomic, strong) UILabel *shareExplanationLabel;
@property (nonatomic, strong) NSMutableArray *shareButtons;

- (instancetype)initWithDelegate:(MAVEShareActions *)delegate;

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
