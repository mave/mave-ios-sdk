//
//  MAVEInviteCopyView.h
//  MaveSDK
//
//  Created by Danny Cosson on 11/18/14.
//  This view goes at the top of the screen to hold copy about the invite program or other message
//  to the user to encourage him/her to invite friends.
//
//  Used as a UITableView.tableHeaderView
//

#import <UIKit/UIKit.h>

@interface MAVEInviteExplanationView : UIView


@property (strong, nonatomic) UILabel *messageCopy;

- (void)setupInit;
- (CGFloat)computeHeightWithWidth:(CGFloat)width;
- (CGSize)messageCopyLabelSizeWithWidth:(CGFloat)width;

@end
