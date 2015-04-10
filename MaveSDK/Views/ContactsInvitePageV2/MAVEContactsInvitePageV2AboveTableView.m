//
//  MAVEContactsInvitePageV2TableHeaderView.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import "MAVEContactsInvitePageV2AboveTableView.h"
#import "MaveSDK.h"

CGFloat const messageViewMargin = 8;
CGFloat const MAVERightMargin = messageViewMargin;
CGFloat const MAVELeftMargin = messageViewMargin;
CGFloat const MAVETopMargin = messageViewMargin;
CGFloat const MAVEMessageViewToSearchBarMargin = messageViewMargin;
CGFloat const MAVEBottomMargin = 0;

CGFloat const MAVESearchBarBorderThickness = 0.5;
CGFloat const MAVESearchBarHeightt = 40;

@implementation MAVEContactsInvitePageV2AboveTableView

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
        [self doSetupConstraints];
    }
    return self;
}

- (void)doInitialSetup {
    self.backgroundColor = [UIColor whiteColor];
    self.topLabelContainerView = [[UIView alloc] init];
    self.topLabelContainerView.backgroundColor = [UIColor redColor];
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.text = @"Message:";
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];

    self.messageTextView = [[UITextView alloc] init];
    self.messageTextView.font = [UIFont systemFontOfSize:18];
    self.messageTextView.scrollEnabled = NO;
    self.messageTextView.text = [MaveSDK sharedInstance].defaultSMSMessageText;
    self.messageTextView.font = [UIFont systemFontOfSize:15];
    self.messageTextView.layer.borderWidth = 0.5;
    self.messageTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.messageTextView.layer.cornerRadius = 4;

    self.searchBarTopBorder = [[UIView alloc] init];
    self.searchBarTopBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.searchBarBottomBorder = [[UIView alloc] init];
    self.searchBarBottomBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.searchBar = [[MAVESearchBar alloc] initWithSingletonSearchBarDisplayOptions];

    [self addSubview:self.topLabelContainerView];
    [self.topLabelContainerView addSubview:self.messageLabel];
    [self.topLabelContainerView addSubview:self.editButton];
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

- (void)doSetupConstraints {
    self.topLabelContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.editButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBarTopBorder.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBarBottomBorder.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *viewsDict = @{@"topLabelContainer": self.topLabelContainerView,
                                @"messageLabel": self.messageLabel,
                                @"editButton": self.editButton,
                                @"messageTextView": self.messageTextView,
                                @"searchBarTopBorder": self.searchBarTopBorder,
                                @"searchBar": self.searchBar,
                                @"searchBarBottomBorder": self.searchBarBottomBorder,
    };

    NSString *sfOuterV = @"V:|-0-[topLabelContainer]-0-[messageTextView]-10-[searchBarTopBorder(==0.5)]-0-[searchBar]-0-[searchBarBottomBorder(==0.5)]-0-|";
    NSString *sfTopContainerH = @"H:|-0-[topLabelContainer]-0-|";
    NSString *sfMessageH = @"H:|-10-[messageTextView]-10-|";
    NSString *sfSearchTopH = @"H:|-0-[searchBarTopBorder]-0-|";
    NSString *sfSearchH = @"H:|-0-[searchBar]-0-|";
    NSString *sfSearchBottomH = @"H:|-0-[searchBarBottomBorder]-0-|";

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfOuterV options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfTopContainerH options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfMessageH options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfSearchTopH options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfSearchH options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfSearchBottomH options:0 metrics:nil views:viewsDict]];

    NSString *sfTopLabelH = @"H:|-10-[messageLabel]-(>=0)-[editButton]-10-|";
    NSString *sfMesageLabelV = @"V:|-(>=0)-[messageLabel]-(>=0)-|";
    NSString *sfEditButtonV = @"V:|-(>=0)-[editButton]-(>=0)-|";
    [self.topLabelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfTopLabelH options:0 metrics:nil views:viewsDict]];
    [self.topLabelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfMesageLabelV options:0 metrics:nil views:viewsDict]];
    [self.topLabelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfEditButtonV options:0 metrics:nil views:viewsDict]];
    // Center the message label and edit button vertically
    [self.topLabelContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.topLabelContainerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.topLabelContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.editButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.topLabelContainerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

//- (void)layoutSubviews {
//    CGSize currentSize = self.frame.size;
//    CGSize msgViewSizeLimit = CGSizeMake(currentSize.width - MAVELeftMargin - MAVERightMargin, CGFLOAT_MAX);
//    CGSize msgViewSize = [self.messageTextView sizeThatFits:msgViewSizeLimit];
//    CGRect newMVFrame = CGRectMake(MAVELeftMargin, MAVETopMargin, msgViewSizeLimit.width, msgViewSize.height);
//    [self.messageTextView setFrame:newMVFrame];
//
//    CGRect newSBTopBorderFrame = CGRectMake(0,
//                                            newMVFrame.origin.y + newMVFrame.size.height + MAVEMessageViewToSearchBarMargin,
//                                            currentSize.width,
//                                            MAVESearchBarBorderThickness);
//    [self.searchBarTopBorder setFrame:newSBTopBorderFrame];
//
//    CGRect newSBFrame = CGRectMake(0,
//                                   newSBTopBorderFrame.origin.y + newSBTopBorderFrame.size.height,
//                                   currentSize.width,
//                                   MAVESearchBarHeightt);
//    [self.searchBar setFrame:newSBFrame];
//
//    CGRect newSBBottomBorderFrame = CGRectMake(0,
//                                               newSBFrame.origin.y + newSBFrame.size.height,
//                                               currentSize.width,
//                                               MAVESearchBarBorderThickness);
//    [self.searchBarBottomBorder setFrame:newSBBottomBorderFrame];
//}

@end