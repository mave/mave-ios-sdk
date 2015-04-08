//
//  MAVEContactsInvitePageV2TableWrapperView.h
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEContactsInvitePageV2TableHeaderView.h"


@interface MAVEContactsInvitePageV2TableWrapperView : UIView

@property (nonatomic, strong) MAVEContactsInvitePageV2TableHeaderView *aboveTableView;
@property (nonatomic, strong) UITableView *tableView;

@end
