//
//  MAVEContactsInvitePageV3TableWrapperView.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVESearchBar.h"
#import "MAVEInvitePageSelectAllRow.h"
#import "MAVEBigSendButton.h"


@interface MAVEContactsInvitePageV3TableWrapperView : UIView

@property (nonatomic, strong) NSLayoutConstraint *topLayoutConstraint;
@property (nonatomic, strong) UIView *aboveTableView;
@property (nonatomic, strong) MAVESearchBar *searchBar;
@property (nonatomic, strong) MAVEInvitePageSelectAllRow *selectAllRow;
@property (nonatomic, strong) NSLayoutConstraint *selectAllRowHeightConstraint;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) MAVEBigSendButton *bigSendButton;
@property (nonatomic, strong) UIView *extraBottomPadding;

@property (nonatomic, assign) CGFloat bigSendButtonHeightWhenExpanded;
@property (nonatomic, strong) NSLayoutConstraint *bigSendButtonBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *extraBottomPaddingHeightConstraint;
- (void)updateBigSendButtonHeightExpanded:(BOOL)expanded animated:(BOOL)animated;

@end
