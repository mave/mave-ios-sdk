//
//  MAVEContactsInvitePageV2TableHeaderView.h
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVESearchBar.h"

@interface MAVEContactsInvitePageV2AboveTableView : UIView

@property (nonatomic, strong) UIView *topLabelContainerView;
@property (nonatomic, strong) UIView *nonSearchContainerView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) NSLayoutConstraint *messageViewHeightConstraint;
@property (nonatomic, strong) MAVESearchBar *searchBar;
@property (nonatomic, strong) UIView *searchBarTopBorder;

- (void)toggleMessageTextViewEditable;


@end
