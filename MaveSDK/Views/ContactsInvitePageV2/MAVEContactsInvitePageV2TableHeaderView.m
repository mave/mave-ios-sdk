//
//  MAVEContactsInvitePageV2TableHeaderView.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import "MAVEContactsInvitePageV2TableHeaderView.h"

CGFloat const messageViewMargin = 8;
CGFloat const MAVERightMargin = messageViewMargin;
CGFloat const MAVELeftMargin = messageViewMargin;
CGFloat const MAVETopMargin = messageViewMargin;
CGFloat const MAVEMessageViewToSearchBarMargin = messageViewMargin;
CGFloat const MAVEBottomMargin = 0;

CGFloat const MAVESearchBarBorderThickness = 0.5;
CGFloat const MAVESearchBarHeightt = 40;

@implementation MAVEContactsInvitePageV2TableHeaderView

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    self.backgroundColor = [UIColor whiteColor];
    self.messageTextView = [[UITextView alloc] init];
    self.messageTextView.font = [UIFont systemFontOfSize:18];
    self.messageTextView.scrollEnabled = NO;
    self.messageTextView.text = @"Check out Shyp: a cool app that helps you ship your stuff. Use my referral ink to get $30 off your first shipment: http://get.shyp.com/ic/dasdn";
    self.messageTextView.font = [UIFont systemFontOfSize:15];
    self.messageTextView.layer.borderWidth = 0.5;
    self.messageTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.messageTextView.layer.cornerRadius = 4;

    self.searchBarTopBorder = [[UIView alloc] init];
    self.searchBarTopBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.searchBarBottomBorder = [[UIView alloc] init];
    self.searchBarBottomBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.searchBar = [[MAVESearchBar alloc] initWithSingletonSearchBarDisplayOptions];

    [self addSubview:self.messageTextView];
    [self addSubview:self.searchBarTopBorder];
    [self addSubview:self.searchBar];
    [self addSubview:self.searchBarBottomBorder];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize msgViewSizeLimit = CGSizeMake(size.width - MAVELeftMargin - MAVERightMargin,
                                         size.height - MAVETopMargin - MAVEBottomMargin);
    CGSize msgViewSize = [self.messageTextView sizeThatFits:msgViewSizeLimit];
    CGSize output = CGSizeMake(size.width,
                               MAVETopMargin
                               + msgViewSize.height + MAVEMessageViewToSearchBarMargin
                               + MAVESearchBarBorderThickness + MAVESearchBarHeightt + MAVESearchBarBorderThickness
                               + MAVEBottomMargin);
    return output;
}

- (void)layoutSubviews {
    CGSize currentSize = self.frame.size;
    CGSize msgViewSizeLimit = CGSizeMake(currentSize.width - MAVELeftMargin - MAVERightMargin, CGFLOAT_MAX);
    CGSize msgViewSize = [self.messageTextView sizeThatFits:msgViewSizeLimit];
    CGRect newMVFrame = CGRectMake(MAVELeftMargin, MAVETopMargin, msgViewSizeLimit.width, msgViewSize.height);
    [self.messageTextView setFrame:newMVFrame];

    CGRect newSBTopBorderFrame = CGRectMake(0,
                                            newMVFrame.origin.y + newMVFrame.size.height + MAVEMessageViewToSearchBarMargin,
                                            currentSize.width,
                                            MAVESearchBarBorderThickness);
    [self.searchBarTopBorder setFrame:newSBTopBorderFrame];

    CGRect newSBFrame = CGRectMake(0,
                                   newSBTopBorderFrame.origin.y + newSBTopBorderFrame.size.height,
                                   currentSize.width,
                                   MAVESearchBarHeightt);
    [self.searchBar setFrame:newSBFrame];

    CGRect newSBBottomBorderFrame = CGRectMake(0,
                                               newSBFrame.origin.y + newSBFrame.size.height,
                                               currentSize.width,
                                               MAVESearchBarBorderThickness);
    [self.searchBarBottomBorder setFrame:newSBBottomBorderFrame];
}

@end