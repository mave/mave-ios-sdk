//
//  MAVEBigSendButton.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import <UIKit/UIKit.h>

@interface MAVEBigSendButton : UIButton

@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *centeredTextLabel;

- (void)updateButtonTextNumberToSend:(NSUInteger)numberToSend;

- (void)updateButtonToSendingStatus;
- (void)updateButtonToSentStatus;

@end
