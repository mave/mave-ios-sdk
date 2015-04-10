//
//  MAVEContactsInvitePageV2TableHeaderView.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import "MAVEContactsInvitePageV2AboveTableView.h"
#import "MaveSDK.h"
#import "MAVESimpleDoneButtonAccessoryView.h"

CGFloat const messageViewMargin = 8;
CGFloat const MAVERightMargin = messageViewMargin;
CGFloat const MAVELeftMargin = messageViewMargin;
CGFloat const MAVETopMargin = messageViewMargin;
CGFloat const MAVEMessageViewToSearchBarMargin = messageViewMargin;
CGFloat const MAVEBottomMargin = 0;

CGFloat const MAVESearchBarBorderThickness = 0.5;
CGFloat const MAVESearchBarHeightt = 40;

CGFloat const messageViewHorizontalMargins = 10;

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

    self.backgroundColor = opts.messageFieldBackgroundColor;

    self.topLabelContainerView = [[UIView alloc] init];
    self.topLabelContainerView.backgroundColor = [UIColor clearColor];
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.text = @"Message:";
    self.messageLabel.font = [UIFont boldSystemFontOfSize:15];
    self.messageLabel.textColor = [UIColor grayColor];
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.editButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.editButton setTitle:@"" forState:UIControlStateSelected];
    [self.editButton addTarget:self action:@selector(toggleMessageTextViewEditable) forControlEvents:UIControlEventTouchUpInside];

    self.messageTextView = [[UITextView alloc] init];
    self.messageTextView.font = opts.messageFieldFont;
    self.messageTextView.textColor = opts.messageFieldTextColor;
    self.messageTextView.scrollEnabled = NO;
    self.messageTextView.text = [MaveSDK sharedInstance].defaultSMSMessageText;
    self.messageTextView.text = @"Hey this is a longer message and it's going to wrap to multiple lines";
    self.messageTextView.editable = NO;
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.returnKeyType = UIReturnKeyDone;

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

- (void)updateConstraints {
    [super updateConstraints];

    if (!CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        CGFloat msgWidth = self.frame.size.width - 2 * messageViewHorizontalMargins;
        CGSize neededMessageTextViewSize = [self.messageTextView sizeThatFits:CGSizeMake(msgWidth, CGFLOAT_MAX)];
        self.messageViewHeightConstraint.constant = neededMessageTextViewSize.height;
    }
}

- (void)doInitialSetupConstraints {
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
    NSDictionary *metrics = @{@"messageTextHMargins": @(messageViewHorizontalMargins)};

    NSString *sfOuterV = @"V:|-0-[topLabelContainer]-(-5)-[messageTextView]-0-[searchBarTopBorder(==0.5)]-0-[searchBar]-0-[searchBarBottomBorder(==0.5)]-0-|";
    NSString *sfTopContainerH = @"H:|-0-[topLabelContainer]-0-|";
    NSString *sfMessageH = @"H:|-messageTextHMargins-[messageTextView]-messageTextHMargins-|";
    NSString *sfSearchTopH = @"H:|-0-[searchBarTopBorder]-0-|";
    NSString *sfSearchH = @"H:|-0-[searchBar]-0-|";
    NSString *sfSearchBottomH = @"H:|-0-[searchBarBottomBorder]-0-|";

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfOuterV options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfTopContainerH options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfMessageH options:0 metrics:metrics views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfSearchTopH options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfSearchH options:0 metrics:nil views:viewsDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfSearchBottomH options:0 metrics:nil views:viewsDict]];

    self.messageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.messageTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    [self addConstraint:self.messageViewHeightConstraint];

    NSString *sfTopLabelH = @"H:|-10-[messageLabel]-(>=0)-[editButton]-10-|";
    NSString *sfMesageLabelV = @"V:|-(>=0)-[messageLabel]-0-|";
    NSString *sfEditButtonV = @"V:|-(>=0)-[editButton]-(-5)-|";
    [self.topLabelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfTopLabelH options:0 metrics:nil views:viewsDict]];
    [self.topLabelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfMesageLabelV options:0 metrics:nil views:viewsDict]];
    [self.topLabelContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sfEditButtonV options:0 metrics:nil views:viewsDict]];
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