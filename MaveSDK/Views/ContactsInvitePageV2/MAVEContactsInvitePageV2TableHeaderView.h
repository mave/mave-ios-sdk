//
//  MAVEContactsInvitePageV2TableHeaderView.h
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVESearchBar.h"

@interface MAVEContactsInvitePageV2TableHeaderView : UIView

@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) MAVESearchBar *searchBar;
@property (nonatomic, strong) UIView *searchBarTopBorder;
@property (nonatomic, strong) UIView *searchBarBottomBorder;


@end
