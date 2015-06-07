//
//  MAVESuggestedInviteReusableCellDelegate.h
//  MaveSDK
//
//  Created by Danny Cosson on 6/5/15.
//
// This class is expected to have several of its methods called by a tableView's data
// source/delegate methods. It controls the cells in one section of the table, and
// handles animating in/out new cells (if there are additional suggestions to display)
// when the user invites or dismisses a suggestion.
//

#import <UIKit/UIKit.h>
#import "MAVESuggestedInviteReusableTableViewCell.h"

@interface MAVESuggestedInviteReusableCellDelegate : NSObject

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) NSInteger sectionNumber;
@property (nonatomic, assign) NSInteger maxNumberOfRows;
@property (nonatomic, strong) NSArray *liveData;
@property (nonatomic, strong) NSArray *standbyData;

- (instancetype)initForTableView:(UITableView *)tableView
                   sectionNumber:(NSInteger)sectionNumber
                 maxNumberOfRows:(NSInteger)maxNumberOfRows;

- (void)getSuggestionsAndLoadAsynchronously;
- (NSInteger)numberOfRows;
- (CGFloat)cellHeight;
- (MAVESuggestedInviteReusableTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// Helpers
- (void)_loadSuggestedInvites:(NSArray *)suggestedInvites;
- (MAVEABPerson *)_contactAtIndexPath:(NSIndexPath *)indexPath;

@end
