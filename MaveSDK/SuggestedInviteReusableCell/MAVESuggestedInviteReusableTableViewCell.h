//
//  MAVESuggestedInviteSingleTableViewCell.h
//  MaveSDK
//
//  Created by Danny Cosson on 6/5/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVEABPerson.h"
#import "MAVEInitialsPictureAlternative.h"

@interface MAVESuggestedInviteReusableTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *pictureView;
@property (nonatomic, strong) MAVEInitialsPictureAlternative *initialsInsteadOfPictureView;
@property (nonatomic, strong) UIView *textContainer;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIButton *sendButton;

// Other layout values
@property (nonatomic, assign) CGFloat pictureViewWidthHeight;
@property (nonatomic, assign) CGFloat buttonWidthHeight;
@property (nonatomic, assign) CGFloat betweenButtonPadding;
@property (nonatomic, assign) CGFloat hLeftPadding;
@property (nonatomic, assign) CGFloat hRightPadding;
@property (nonatomic, assign) CGFloat vPicturePadding;

- (CGFloat)cellHeight;

- (void)updateForUseWithContact:(MAVEABPerson *)contact;
- (void)_updatePictureViewWithPicture:(UIImage *)picture orInitials:(NSString *)initials;

@end
