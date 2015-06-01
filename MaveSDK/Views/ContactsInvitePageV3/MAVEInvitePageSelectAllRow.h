//
//  MAVEInvitePageSelectAllRow.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/28/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVECustomCheckboxV3.h"

@interface MAVEInvitePageSelectAllRow : UIView

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) MAVECustomCheckboxV3 *checkbox;
@property (nonatomic, strong) UIView *topSeparatorBar;
@property (nonatomic, strong) UIView *bottomSeparatorBar;
@property (nonatomic, strong) void(^selectAllBlock)(BOOL selected);

@end
