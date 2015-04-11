//
//  MAVEInviteTableHeaderView.h
//  MaveSDK
//
//  Created by Mave on 12/22/14.
//
//

#import <UIKit/UIKit.h>
#import "MAVEInviteExplanationView.h"
#import "MAVESearchBar.h"
#import "MAVEShareButtonsView.h"

#define MAVE_DEFAULT_SEARCH_BAR_HEIGHT 44

@interface MAVEInviteTableHeaderView : UIView

@property (nonatomic, assign) BOOL showsExplanation;
@property (nonatomic, assign) BOOL showsShareButtons;

@property (nonatomic, strong) MAVEInviteExplanationView *inviteExplanationView;
@property (nonatomic, strong) MAVEShareButtonsView *shareButtonsView;
@property (nonatomic, strong) UIView *searchBarTopBorder;
@property (nonatomic, strong) MAVESearchBar *searchBar;

// This method determines whether or not we need to display this
// view at all. Currently, the only content to show is explanation
// copy (the search bar doesn't count, b/c if the search bar is the
// only content we can just use the fixed search bar permanently
// instead of starting with a fake search bar in this view).
- (BOOL)hasContentOtherThanSearchBar;

- (CGFloat)computeHeightWithWidth:(CGFloat)width;
- (void)resizeWithShiftedOffsetY:(CGFloat)shiftedOffsetY;

@end
