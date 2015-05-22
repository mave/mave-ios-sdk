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
@property (nonatomic, assign) CGFloat contactInfoHeightSpacingBetweenRows;
@property (nonatomic, assign) CGFloat bottomSeparatorHeight;
@property (nonatomic, strong) UIFont *contactInfoFont;


@property (nonatomic, assign) CGFloat pictureWidthHeight;
@property (nonatomic, strong) UIImageView *picture;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *contactInfoContainer;
@property (nonatomic, strong) UIView *bottomSeparator;
@property (nonatomic, strong) MAVECustomCheckboxV3 *checkmarkBox;

- (void)updateForReuseWithPerson:(MAVEABPerson *)person;

- (CGFloat)heightGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords;
- (CGFloat)_heightOfContactInfoWrapperGivenNumberOfContactInfoRecords:(NSUInteger)numberContactRecords;

@end
