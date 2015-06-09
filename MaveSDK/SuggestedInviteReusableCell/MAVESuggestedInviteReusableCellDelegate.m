//
//  MAVESuggestedInviteReusableCellDelegate.m
//  MaveSDK
//
//  Created by Danny Cosson on 6/5/15.
//
//

#import "MAVESuggestedInviteReusableCellDelegate.h"
#import "MAVESuggestedInviteReusableTableViewCell.h"
#import "MaveSDK.h"

NSString * const MAVESuggestedInviteReusableCellIdentifier = @"MAVESuggestedInviteReusableCellIdentifier";

@implementation MAVESuggestedInviteReusableCellDelegate

- (instancetype)initForTableView:(UITableView *)tableView sectionNumber:(NSInteger)sectionNumber maxNumberOfRows:(NSInteger)maxNumberOfRows {
    if (self = [super init]) {
        self.tableView = tableView;
        self.sectionNumber = sectionNumber;
        self.maxNumberOfRows = maxNumberOfRows;
        [self doInitialSetup];
    }
    return self;
}

- (void)doInitialSetup {
    [self.tableView registerClass:[MAVESuggestedInviteReusableTableViewCell class]
           forCellReuseIdentifier:MAVESuggestedInviteReusableCellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    MAVESuggestedInviteReusableTableViewCell *tmpCell = [[MAVESuggestedInviteReusableTableViewCell alloc] init];
    self.cellHeight = [tmpCell cellHeight];
    self.inviteFriendsCell = [[MAVESuggestedInviteReusableInviteFriendsButtonTableViewCell alloc] init];
}

- (void)getSuggestionsAndLoadAnimated:(BOOL)animated withCompletionBlock:(void (^)(NSUInteger))initialLoadCompletionBlock {
    [[MaveSDK sharedInstance] getSuggestedInvites:^(NSArray *suggestedInvites) {
        [self _loadSuggestedInvites:suggestedInvites];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (animated) {
                NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                for (NSInteger i = 0; i < [suggestedInvites count]; i++) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:self.sectionNumber]];
                }
                if ([indexPaths count] > 0) {
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
                    [self.tableView endUpdates];
                }
            }
            [self.tableView reloadData];
            if (initialLoadCompletionBlock) {
                initialLoadCompletionBlock([suggestedInvites count]);
            }
        });
    } timeout:5];
}

- (void)_loadSuggestedInvites:(NSArray *)suggestedInvites {
    NSMutableArray *liveData = [[NSMutableArray alloc] init];
    NSMutableArray *extraData = [[NSMutableArray alloc] init];
    for (id row in suggestedInvites) {
        if ([liveData count] < self.maxNumberOfRows) {
            [liveData addObject:row];
        } else {
            [extraData addObject:row];
        }
    }
    self.liveData = [NSArray arrayWithArray:liveData];
    self.standbyData = [NSArray arrayWithArray:extraData];
}

- (MAVESuggestedInviteReusableTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Last row should be our invite friends cell
    if (indexPath.row == [self numberOfRows] - 1) {
        return self.inviteFriendsCell;
    }
    MAVEABPerson *contact = [self _contactAtIndexPath:indexPath];
    if (!contact) {
        return nil;
    }
    MAVESuggestedInviteReusableTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MAVESuggestedInviteReusableCellIdentifier];
    [cell updateForUseWithContact:contact dismissBlock:^{
        [self _replaceCellAtIndexPath:indexPath deleteAnimation:UITableViewRowAnimationLeft];
    } inviteBlock:^{
        [self _replaceCellAtIndexPath:indexPath deleteAnimation:UITableViewRowAnimationRight];
    }];
    return cell;
}

- (MAVEABPerson *)_contactAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != self.sectionNumber) {
        return nil;
    }
    if (indexPath.row >= [self.liveData count]) {
        return nil;
    }
    return [self.liveData objectAtIndex:indexPath.row];
}

- (void)_replaceCellAtIndexPath:(NSIndexPath *)indexPath deleteAnimation:(UITableViewRowAnimation)deleteAnimation {
    NSMutableArray *tmpLiveData = [[NSMutableArray alloc] initWithArray:self.liveData];
    [tmpLiveData removeObjectAtIndex:indexPath.row];
    NSIndexPath *insertAtIndexPath = nil;
    if ([self.standbyData count] > 0) {
        NSMutableArray *tmpStandbyData = [[NSMutableArray alloc] initWithArray:self.standbyData];
        MAVEABPerson *upNext = [tmpStandbyData objectAtIndex:0];
        [tmpStandbyData removeObjectAtIndex:0];
        self.standbyData = [[NSArray alloc] initWithArray:tmpStandbyData];
        if (upNext) {
            [tmpLiveData addObject:upNext];
            insertAtIndexPath = [NSIndexPath indexPathForRow:([tmpLiveData count]-1) inSection:self.sectionNumber];
        }
    }
    self.liveData = [[NSArray alloc] initWithArray:tmpLiveData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:deleteAnimation];
        if (insertAtIndexPath) {
            [self.tableView insertRowsAtIndexPaths:@[insertAtIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        }
        [self.tableView endUpdates];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (NSInteger)numberOfRows {
    return [self.liveData count] + 1;
}

- (BOOL)isLastRow:(NSIndexPath *)indexPath {
    return indexPath.section == self.sectionNumber && indexPath.row == [self numberOfRows] - 1;
}

@end
