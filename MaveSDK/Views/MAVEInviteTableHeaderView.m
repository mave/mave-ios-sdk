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

- (instancetype)initWithShareDelegate:(id<MAVEShareButtonsDelegate>)shareDelegate {
    if (self = [super init]) {
        self.shareDelegate = shareDelegate;
        [self setupInit];
    }
    return self;
}

- (void)setupInit {
    MAVEDisplayOptions *displayOptions = [MaveSDK sharedInstance].displayOptions;

    _showsExplanation = [MaveSDK sharedInstance].inviteExplanationCopy.length > 0;
    _showsShareButtons = [MaveSDK sharedInstance].remoteConfiguration.contactsInvitePage.shareButtonsEnabled;

    if ([self hasContentOtherThanSearchBar]) {
        self.backgroundColor = displayOptions.inviteExplanationCellBackgroundColor;
    }

    if (self.showsExplanation) {
        self.inviteExplanationView = [[MAVEInviteExplanationView alloc] init];
        [self addSubview:self.inviteExplanationView];
    }

    if (self.showsShareButtons) {
        self.shareButtonsView = [[MAVEShareButtonsView alloc] initWithDelegate:self.shareDelegate iconColor:displayOptions.inviteExplanationShareButtonsColor iconFont:displayOptions.inviteExplanationShareButtonsFont backgroundColor:displayOptions.inviteExplanationShareButtonsBackgroundColor useSmallIcons:YES];
        [self addSubview:self.shareButtonsView];
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

- (BOOL)hasContentOtherThanSearchBar {
    return self.showsExplanation || self.showsShareButtons;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.frame;
    CGFloat inviteExplanationViewHeight = 0;
    CGFloat searchBarTopY = 0;
    if (self.showsExplanation) {
        // Reposition the inviteExplanationView based on width of text
        inviteExplanationViewHeight = ceil([self.inviteExplanationView
                                            computeHeightWithWidth:frame.size.width]);
        searchBarTopY = inviteExplanationViewHeight;
        CGRect newInviteExplanationViewRect = CGRectMake(0, 0, frame.size.width,
                                                         inviteExplanationViewHeight);
        self.inviteExplanationView.frame = newInviteExplanationViewRect;
    }

    CGFloat shareButtonsHeight = 0;
    if (self.showsShareButtons) {
        shareButtonsHeight = [self.shareButtonsView sizeThatFits:frame.size].height;
        CGFloat yoffset = 0;
        if (self.showsExplanation) {
            // take off the invite explanation margin so there's less space between share
            // buttons and explanation copy
            yoffset = inviteExplanationViewHeight - 15;
        }
        searchBarTopY = yoffset + shareButtonsHeight;
        self.shareButtonsView.frame = CGRectMake(0,
                                           yoffset,
                                           frame.size.width,
                                           shareButtonsHeight);
    }

    CGRect searchBarTopBorderFrame = self.searchBarTopBorder.frame;
    searchBarTopBorderFrame.origin.y =  searchBarTopY;
    searchBarTopBorderFrame.size.width = frame.size.width;
    self.searchBarTopBorder.frame = searchBarTopBorderFrame;
    [self bringSubviewToFront:self.searchBarTopBorder];
}

- (CGFloat)computeHeightWithWidth:(CGFloat)width {
    CGFloat height = 0;
    if (self.showsExplanation) {
        height += [self.inviteExplanationView computeHeightWithWidth:width];
    }

    if (self.showsShareButtons) {
        height += [self.shareButtonsView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
        if (self.showsExplanation) {
            // take off the invite explanation margin so there's less space between share
            // buttons and explanation copy
            height -= 15;
        }
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
