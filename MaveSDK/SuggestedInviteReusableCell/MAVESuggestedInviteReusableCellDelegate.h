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
#import "MAVESuggestedInviteReusableInviteFriendsButtonTableViewCell.h"

@interface MAVESuggestedInviteReusableCellDelegate : NSObject

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) NSInteger sectionNumber;
@property (nonatomic, assign) NSInteger maxNumberOfRows;
@property (nonatomic, strong) NSArray *liveData;
@property (atomic, strong) NSDictionary *recordIDToIndexMap;
@property (nonatomic, strong) NSArray *standbyData;
@property (nonatomic, assign) BOOL includeInviteFriendsCell;
@property (nonatomic, strong) MAVESuggestedInviteReusableInviteFriendsButtonTableViewCell *inviteFriendsCell;
@property (nonatomic, copy) NSString *suggestionsCellInviteContext;
@property (nonatomic, copy) NSString *fullContactsPageInviteContext;

// Callbacks so the app integrating can track user interactions with these cells
@property (nonatomic, copy) void (^dismissedSuggestedCellBlock)(MAVEABPerson *contact);
@property (nonatomic, copy) void (^sentToSuggestedCellBlock)(MAVEABPerson *contact);
// For a callback for clicking the round invite friends button (if it's enabled)
// set it directly as inviteFriendsCell.inviteFriendsButton.openedInvitePageBlock

- (instancetype)initForTableView:(UITableView *)tableView
                   sectionNumber:(NSInteger)sectionNumber
                 maxNumberOfRows:(NSInteger)maxNumberOfRows;

- (void)getSuggestionsAndLoadAnimated:(BOOL)animated withCompletionBlock:(void(^)(NSUInteger numberOfSuggestions))initialLoadCompletionBlock;

- (NSInteger)numberOfRows;
- (CGFloat)cellHeight;
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

// Helpers
- (void)_loadSuggestedInvites:(NSArray *)suggestedInvites;
- (MAVEABPerson *)_contactAtIndexPath:(NSIndexPath *)indexPath;
- (void)_replaceCellForContact:(MAVEABPerson *)contact afterDelay:(CGFloat)delaySeconds deleteAnimation:(UITableViewRowAnimation)deleteAnimation;

- (void)sendInviteToContact:(MAVEABPerson *)contact;

@end
