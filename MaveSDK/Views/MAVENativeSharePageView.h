//
//  MAVENativeSharePageView.h
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVENativeSharePageView : UIView

@property (nonatomic, strong) UILabel *shareExplanationLabel;
@property (nonatomic, strong) NSMutableArray *shareButtons;

// Helpers
- (CGSize)shareButtonSize;  // all share buttons should be the same size

- (UIButton *)smsInviteButton;
- (UIButton *)facebookShareButton;

@end
