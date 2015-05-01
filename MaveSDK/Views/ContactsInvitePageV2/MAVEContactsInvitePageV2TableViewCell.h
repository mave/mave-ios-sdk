//
//  MAVEContactsInvitePageV2TableViewCell2.h
//  MaveSDK
//
//  Created by Danny Cosson on 4/9/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEABPerson.h"
#import "MAVEContactsInvitePageV2ViewController.h"
#import "MAVEContactsInvitePageInlineSendButton.h"

@interface MAVEContactsInvitePageV2TableViewCell : UITableViewCell

@property (nonatomic, weak) MAVEContactsInvitePageV2ViewController *delegateController;
@property (nonatomic, weak) MAVEABPerson *person;
@property (nonatomic, assign) BOOL isSuggestedInviteCell;
//@property (strong, nonatomic) UIView *contentWrapper;
@property (strong, nonatomic) UIView *contactInfoWrapper;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet MAVEContactsInvitePageInlineSendButton *sendButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *expandedContactInfoHeightConstraint;

// Initialization methods
- (void) doCreateSubviews;
- (void) doStylingSetup;
- (void) doConstraintSetup;

+ (CGFloat) heightCellWithHave;

- (void)updateWithInfoForPerson:(MAVEABPerson *)person;
- (void)updateWithInfoForNoPersonFound;
- (void)sendInviteToCurrentPerson;

@end
