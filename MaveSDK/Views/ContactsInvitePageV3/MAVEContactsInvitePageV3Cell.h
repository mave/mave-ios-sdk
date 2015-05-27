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

@interface MAVEContactsInvitePageV3Cell : UITableViewCell

// Cell layout constants
@property (nonatomic, assign) CGFloat topToNameLabel;
@property (nonatomic, assign) CGFloat nameLabelToContactInfoWrapper;
@property (nonatomic, assign) CGFloat contactInfoWrapperToBottom;
@property (nonatomic, assign) CGFloat contactInfoWrapperCollapsedHeight;
@property (nonatomic, assign) CGFloat bottomSeparatorHeight;
@property (nonatomic, strong) UIFont *contactInfoFont;

@property (nonatomic, assign) BOOL isExpanded;
// This flag lets the user de-select all the phones/emails in the list without the cell collapsing
// from its expanded state, in case the user intends to deselect one and then select another.
// Since this is set on the cell (which gets reset when re-used) rather than the person, if user
// deselects all numbers, then scrolls away, then scrolls back, the record is no longer expanded
// which is intended behavior since the record isn't actually selected
@property (nonatomic, assign) BOOL forceKeepExpandedUntilDataReloads;

@property (nonatomic, assign) CGFloat pictureWidthHeight;
@property (nonatomic, strong) UIImageView *picture;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *contactInfoContainer;
@property (nonatomic, strong) NSLayoutConstraint *overridingContactInfoContainerHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomContactInfoToContainerBottomConstraint;
@property (nonatomic, strong) UIView *bottomSeparator;
@property (nonatomic, strong) MAVECustomCheckboxV3 *checkmarkBox;

@property (nonatomic, strong) MAVEABPerson *person;
- (void)updateForReuseWithPerson:(MAVEABPerson *)person;

- (UITableView *)containingTableView;
- (CGFloat)heightGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords;
- (CGFloat)_heightOfContactInfoWrapperGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords;

@end
