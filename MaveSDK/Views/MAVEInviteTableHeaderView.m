//
//  MAVEInviteTableHeaderView.m
//  MaveSDK
//
//  Created by Mave on 12/22/14.
//
//

#import "MAVEInviteTableHeaderView.h"
#import "MaveSDK.h"
#import "MAVEDisplayOptions.h"
#import "MAVESearchBar.h"

@implementation MAVEInviteTableHeaderView

- (instancetype)init {
    if (self = [super init]) {
        [self setupInit];
    }
    return self;
}

- (void)setupInit {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    _showsExplanation = displayOptions.inviteExplanationCopy.length > 0;
    if (self.showsExplanation) {
        self.inviteExplanationView = [[MAVEInviteExplanationView alloc] init];
        [self addSubview:self.inviteExplanationView];
        self.backgroundColor = displayOptions.inviteExplanationCellBackgroundColor;
    }

    self.searchBar = [[MAVESearchBar alloc] initWithSingletonSearchBarDisplayOptions];
    self.searchBar.frame = CGRectMake(0,
                                      self.frame.size.height - MAVE_DEFAULT_SEARCH_BAR_HEIGHT,
                                      self.frame.size.width,
                                      MAVE_DEFAULT_SEARCH_BAR_HEIGHT);
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.searchBar];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.frame;

    if (self.showsExplanation) {
        // Reposition the inviteExplanationView based on width of text
        CGFloat inviteExplanationViewHeight = ceil([self.inviteExplanationView
                                                    computeHeightWithWidth:frame.size.width]);
        CGRect newInviteExplanationViewRect = CGRectMake(0, 0, frame.size.width,
                                                         inviteExplanationViewHeight);
        self.inviteExplanationView.frame = newInviteExplanationViewRect;
    }
}

- (CGFloat)computeHeightWithWidth:(CGFloat)width {
    CGFloat searchBarHeight = self.searchBar.frame.size.height;
    if (self.showsExplanation) {
        return [self.inviteExplanationView computeHeightWithWidth:width] + searchBarHeight;
    } else {
        return searchBarHeight;
    }
}

- (void)resizeWithShiftedOffsetY:(CGFloat)shiftedOffsetY {
    // TODO: use a container view so this is 0
    CGFloat DEFAULT_INNER_EXPLANATION_OFFSET = 20;
    if (shiftedOffsetY < 0) {
        CGRect explanationTextFrame = self.inviteExplanationView.messageCopy.frame;
        explanationTextFrame.origin.y =
            roundf(DEFAULT_INNER_EXPLANATION_OFFSET + (shiftedOffsetY / 2) - MAVESearchBarHeight);
        self.inviteExplanationView.messageCopy.frame = explanationTextFrame;
    }
}

@end
