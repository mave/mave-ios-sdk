//
//  MAVEInviteTableHeaderView.h
//  MaveSDK
//
//  Created by Mave on 12/22/14.
//
//

#import <UIKit/UIKit.h>
#import "MAVEInviteExplanationView.h"

#define MAVE_DEFAULT_SEARCH_BAR_HEIGHT 44

@interface MAVEInviteTableHeaderView : UIView

@property (readonly, assign) BOOL showsExplanation;

@property (nonatomic, strong) MAVEInviteExplanationView *inviteExplanationView;
@property (nonatomic, strong) UISearchBar *searchBar;

- (void)repositionSearchBar;
- (CGFloat)computeHeightWithWidth:(CGFloat)width;
- (void)resizeWithShiftedOffsetY:(CGFloat)shiftedOffsetY;

@end
