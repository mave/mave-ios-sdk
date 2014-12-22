//
//  MAVEInviteTableHeaderView.h
//  MaveSDK
//
//  Created by Mave on 12/22/14.
//
//

#import <UIKit/UIKit.h>
#import "MAVEInviteExplanationView.h"

@interface MAVEInviteTableHeaderView : UIView

@property (readonly, assign) BOOL showsExplanation;

@property (nonatomic, strong) MAVEInviteExplanationView *inviteExplanationView;
@property (nonatomic, strong) UISearchBar *searchBar;

- (CGFloat)computeHeightWithWidth:(CGFloat)width;
- (void)resizeWithShiftedOffsetY:(CGFloat)shiftedOffsetY;

@end
