//
//  MAVEContactsInvitePageV2TableHeaderView.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import "MAVEContactsInvitePageV2AboveTableView.h"
#import "MAVESpinnerImageView.h"
#import "MaveSDK.h"

CGFloat const messageViewLeftMargin = 10;
CGFloat const editButtonWidth = 50;

@implementation MAVEContactsInvitePageV2AboveTableView

- (instancetype)init {
    if (self = [super init]) {
        [self doInitialSetup];
        [self doInitialSetupConstraints];
    }
    return self;
}

- (void)doInitialSetup {
    MAVEDisplayOptions *opts = [MaveSDK sharedInstance].displayOptions;

    self.backgroundColor = opts.topViewBackgroundColor;

    self.topLabelContainerView = [[UIView alloc] init];
    self.topLabelContainerView.backgroundColor = [UIColor clearColor];
    self.nonSearchContainerView = [[UIView alloc] init];
    self.nonSearchContainerView.backgroundColor = [UIColor clearColor];
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.text = @"Message:";
    self.messageLabel.font = opts.topViewMessageLabelFont;
    self.messageLabel.textColor = opts.topViewMessageLabelTextColor;
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.backgroundColor = [UIColor clearColor];
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [self.editButton setTitle:@"\u270E" forState:UIControlStateNormal];
    [self.editButton setTitleColor:opts.topViewMessageLabelTextColor forState:UIControlStateNormal];
    [self.editButton setTitle:@"" forState:UIControlStateSelected];
    [self.editButton addTarget:self action:@selector(toggleMessageTextViewEditable) forControlEvents:UIControlEventTouchUpInside];

    self.messageTextView = [[UITextView alloc] init];
    self.messageTextView.font = opts.topViewMessageFont;
    self.messageTextView.textColor = opts.topViewMessageTextColor;
    self.messageTextView.scrollEnabled = NO;
    self.messageTextView.text = [MaveSDK sharedInstance].defaultSMSMessageText;
    self.messageTextView.editable = NO;
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.returnKeyType = UIReturnKeyDone;

    self.searchBarTopBorder = [[UIView alloc] init];
    self.searchBarTopBorder.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.searchBar = [[MAVESearchBar alloc] initWithSingletonSearchBarDisplayOptions];

    [self addSubview:self.nonSearchContainerView];
    [self.nonSearchContainerView addSubview:self.topLabelContainerView];
    [self.nonSearchContainerView addSubview:self.messageTextView];
    [self.nonSearchContainerView addSubview:self.editButton];
    [self.topLabelContainerView addSubview:self.messageLabel];
    [self addSubview:self.searchBarTopBorder];
    [self addSubview:self.searchBar];
}

- (void)updateConstraints {
    [super updateConstraints];

    if (!CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        CGFloat msgWidth = self.frame.size.width - messageViewLeftMargin - editButtonWidth;
        CGSize neededMessageTextViewSize = [self.messageTextView sizeThatFits:CGSizeMake(msgWidth, CGFLOAT_MAX)];
        self.messageViewHeightConstraint.constant = neededMessageTextViewSize.height;
    }
}

- (void)doInitialSetupConstraints {
    self.topLabelContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.nonSearchContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.editButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBarTopBorder.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *viewsDict = @{@"topLabelContainer": self.topLabelContainerView,
                                @"nonSearchContainer": self.nonSearchContainerView,
                                @"messageLabel": self.messageLabel,
                                @"editButton": self.editButton,
                                @"messageTextView": self.messageTextView,
                                @"searchBarTopBorder": self.searchBarTopBorder,
                                @"searchBar": self.searchBar,
    };
    NSDictionary *metrics = @{@"messageLabelLeftMargin": @(14),
                              @"messageTextLeftMargin": @(messageViewLeftMargin),
                              @"editButtonWidth": @(editButtonWidth)};

    NSString *sfOuterV = @"V:|-0-[nonSearchContainer]-0-[searchBarTopBorder(==0.5)]-0-[searchBar]-0-|";
    NSString *sfNonSearchContainerH = @"H:|-0-[nonSearchContainer]-0-|";
    NSString *sfNonSearchInnerV = @"V:|-5-[topLabelContainer]-(-5)-[messageTextView]-0-|";
    NSString *sfTopContainerH = @"H:|-0-[topLabelContainer]-0-|";
    NSString *sfEditButtonV = @"V:|-(>=0)-[editButton(40)]-(-5)-|";
    NSString *sfMessageH = @"H:|-messageTextLeftMargin-[messageTextView]-0-[editButton(editButtonWidth)]-0-|";
    NSString *sfSearchTopH = @"H:|-0-[searchBarTopBorder]-0-|";
    NSString *sfSearchH = @"H:|-0-[searchBar]-0-|";

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfOuterV options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfNonSearchContainerH options:0 metrics:nil views:viewsDict]];
    [self.nonSearchContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfNonSearchInnerV options:0 metrics:nil views:viewsDict]];
    [self.nonSearchContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfTopContainerH options:0 metrics:nil views:viewsDict]];
    [self.nonSearchContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfEditButtonV options:0 metrics:nil views:viewsDict]];
    [self.nonSearchContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfMessageH options:0 metrics:metrics views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfSearchTopH options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfSearchH options:0 metrics:nil views:viewsDict]];

    self.messageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.messageTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    [self.nonSearchContainerView addConstraint:self.messageViewHeightConstraint];

    NSString *sfTopLabelH = @"H:|-messageLabelLeftMargin-[messageLabel]-(>=0)-|";
    NSString *sfMesageLabelV = @"V:|-0-[messageLabel]-0-|";
    [self.topLabelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfTopLabelH options:0 metrics:metrics views:viewsDict]];
    [self.topLabelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfMesageLabelV options:0 metrics:metrics views:viewsDict]];
}

- (void)toggleMessageTextViewEditable {
    self.messageTextView.editable = !self.messageTextView.editable;
    self.editButton.selected = !self.editButton.selected;
    if (self.messageTextView.editable) {
        [self.messageTextView becomeFirstResponder];
    } else {
        [self.messageTextView endEditing:YES];
    }
}

@end