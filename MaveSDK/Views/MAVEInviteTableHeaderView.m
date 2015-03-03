//
//  MAVEInviteTableHeaderView.m
//  MaveSDK
//
//  Created by Mave on 12/22/14.
//
//

#import "MAVEInviteTableHeaderView.h"
#import "MaveSDK.h"
#import "MaveSDK_Internal.h"
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

    _showsExplanation = [MaveSDK sharedInstance].inviteExplanationCopy.length > 0;
    if (self.showsExplanation) {
        self.inviteExplanationView = [[MAVEInviteExplanationView alloc] init];
        [self addSubview:self.inviteExplanationView];
        self.backgroundColor = displayOptions.inviteExplanationCellBackgroundColor;
    }

    self.searchBarTopBorder = [[UIView alloc] init];
    self.searchBarTopBorder.backgroundColor = displayOptions.searchBarTopBorderColor;
    self.searchBarTopBorder.hidden = NO;
    self.searchBarTopBorder.frame = CGRectMake(0, 0, 0, 1);
    [self addSubview:self.searchBarTopBorder];

    self.searchBar = [[MAVESearchBar alloc] initWithSingletonSearchBarDisplayOptions];
    self.searchBar.frame = CGRectMake(0,
                                      self.frame.size.height - MAVESearchBarHeight,
                                      self.frame.size.width,
                                      MAVESearchBarHeight);
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.searchBar];
}

- (BOOL)hasContentToShow {
    return self.showsExplanation;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.frame;
    CGFloat inviteExplanationViewHeight = 0;
    if (self.showsExplanation) {
        // Reposition the inviteExplanationView based on width of text
        inviteExplanationViewHeight = ceil([self.inviteExplanationView
                                            computeHeightWithWidth:frame.size.width]);
        CGRect newInviteExplanationViewRect = CGRectMake(0, 0, frame.size.width,
                                                         inviteExplanationViewHeight);
        self.inviteExplanationView.frame = newInviteExplanationViewRect;
    }

    CGRect searchBarTopBorderFrame = self.searchBarTopBorder.frame;
    searchBarTopBorderFrame.origin.y = inviteExplanationViewHeight;
    searchBarTopBorderFrame.size.width = frame.size.width;
    self.searchBarTopBorder.frame = searchBarTopBorderFrame;
    [self bringSubviewToFront:self.searchBarTopBorder];
}

- (CGFloat)computeHeightWithWidth:(CGFloat)width {
    CGFloat height = 0;
    if (self.showsExplanation) {
        height += [self.inviteExplanationView computeHeightWithWidth:width];
    }
    height += self.searchBar.frame.size.height;
    return height;
}

- (void)resizeWithShiftedOffsetY:(CGFloat)shiftedOffsetY {
    // this is how far from the origin we want the text to be when page is static
    CGFloat DEFAULT_INNER_EXPLANATION_OFFSET = 20;
    if (shiftedOffsetY < 0) {
        CGRect explanationTextFrame = self.inviteExplanationView.messageCopy.frame;
        CGFloat newYCoord =
            roundf(DEFAULT_INNER_EXPLANATION_OFFSET
                   + (shiftedOffsetY / 2));
        explanationTextFrame.origin.y = newYCoord;
        self.inviteExplanationView.messageCopy.frame = explanationTextFrame;
    }
}

@end
