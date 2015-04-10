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

@interface MAVEContactsInvitePageV2TableViewCell2 : UITableViewCell

@property (nonatomic, weak) MAVEContactsInvitePageV2ViewController *delegateController;
@property (nonatomic, weak) MAVEABPerson *person;
//@property (strong, nonatomic) UIView *contentWrapper;
@property (strong, nonatomic) UIView *contactInfoWrapper;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *expandedContactInfoHeightConstraint;


- (void)updateWithInfoForPerson:(MAVEABPerson *)person;
- (void)updateWithInfoForNoPersonFound;
- (void)sendInviteToCurrentPerson;

@end
