//
//  MAVEContactsInvitePageV3TableWrapperView.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEBigSendButton.h"

@interface MAVEContactsInvitePageV3TableWrapperView : UIView

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MAVEBigSendButton *bigSendButton;

@property (nonatomic, strong) NSLayoutConstraint *bigSendButtonHeightConstraint;

@end
