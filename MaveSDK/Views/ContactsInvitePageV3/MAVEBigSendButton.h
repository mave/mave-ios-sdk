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

- (void)updateButtonTextNumberToSend:(NSUInteger)numberToSend;

@end
