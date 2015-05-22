//
//  MAVEContactsInvitePageV3Cell.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVECustomCheckboxV3.h"

@interface MAVEContactsInvitePageV3Cell : UITableViewCell

@property (nonatomic, strong) UIImageView *picture;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *contactInfoContainerView;
@property (nonatomic, strong) MAVECustomCheckboxV3 *checkmarkBox;

@end
