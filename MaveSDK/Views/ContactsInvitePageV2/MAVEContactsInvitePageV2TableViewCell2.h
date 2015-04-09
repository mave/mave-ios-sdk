//
//  MAVEContactsInvitePageV2TableViewCell2.h
//  MaveSDK
//
//  Created by Danny Cosson on 4/9/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEABPerson.h"

@interface MAVEContactsInvitePageV2TableViewCell2 : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactInfoLabel;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *expandedContactInfoHeightConstraint;
- (void)doInitialSetup;
- (void)updateWithInfoForPerson:(MAVEABPerson *)person;
- (void)updateWithInfoForNoPersonFound;

@end
