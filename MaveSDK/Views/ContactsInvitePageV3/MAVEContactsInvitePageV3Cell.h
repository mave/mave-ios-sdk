//
//  MAVEContactsInvitePageV3Cell.h
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import <UIKit/UIKit.h>
#import "MAVECustomCheckboxV3.h"
#import "MAVEABPerson.h"
#import "MAVEInitialsPictureAlternative.h"

@interface MAVEContactsInvitePageV3Cell : UITableViewCell

// Cell layout constants
@property (nonatomic, assign) CGFloat topToNameLabel;
@property (nonatomic, assign) CGFloat nameLabelToContactInfoWrapper;
@property (nonatomic, assign) CGFloat contactInfoWrapperToBottom;
@property (nonatomic, assign) CGFloat contactInfoWrapperCollapsedHeight;
@property (nonatomic, assign) CGFloat bottomSeparatorHeight;
@property (nonatomic, strong) UIFont *contactInfoFont;

@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) CGFloat pictureWidthHeight;
@property (nonatomic, strong) UIImageView *pictureView;
@property (nonatomic, strong) MAVEInitialsPictureAlternative *initialsInsteadOfPictureView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *contactInfoContainer;
@property (nonatomic, strong) NSLayoutConstraint *overridingContactInfoContainerHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomContactInfoToContainerBottomConstraint;
@property (nonatomic, strong) UIView *bottomSeparator;
@property (nonatomic, strong) MAVECustomCheckboxV3 *checkmarkBox;
@property (nonatomic, strong) void (^contactIdentifiersSelectedDidUpdateBlock)(MAVEABPerson *person);

@property (nonatomic, strong) MAVEABPerson *person;
- (void)updateForReuseWithPerson:(MAVEABPerson *)person;
- (void)updateForNoPersonFoundUse;

- (UITableView *)containingTableView;
- (CGFloat)heightGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords;
- (CGFloat)_heightOfContactInfoWrapperGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords;
- (void)updatePictureViewPicture:(UIImage *)picture initials:(NSString *)initials;

@end
