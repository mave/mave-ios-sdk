//
//  MAVEContactsInvitePageInlineSendButton.h
//  MaveSDK
//
//  Created by Danny Cosson on 4/13/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVESpinnerImageView.h"

@interface MAVEContactsInvitePageInlineSendButton : UIButton

@property (nonatomic, copy) NSString *sendActionCopy;
@property (nonatomic, copy) NSString *sentStateCopy;
@property (nonatomic, strong) MAVESpinnerImageView *sendingStatusSpinner;

- (void)setStatusUnsent;
- (void)setStatusSending;
- (void)setStatusSent;

@end
