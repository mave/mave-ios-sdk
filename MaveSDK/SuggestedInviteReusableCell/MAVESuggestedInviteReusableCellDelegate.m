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
#import "MAVEConstants.h"

NSString * const MAVESuggestedInviteReusableCellIdentifier = @"MAVESuggestedInviteReusableCellIdentifier";

@implementation MAVESuggestedInviteReusableCellDelegate {
    BOOL _tableDataLoaded;
}

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
    [self.inviteFriendsCell updateConstraints];

    [self setFullContactsPageInviteContext:@"InvitePageFromBottomOfReusableSuggestionsTable"];
    [self setSuggestionsCellInviteContext:@"ReusableSuggestionCell"];
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
    for (MAVEABPerson *person in suggestedInvites) {
        if ([liveData count] < self.maxNumberOfRows) {
            [liveData addObject:person];
        } else {
            [extraData addObject:person];
        }
    }
    self.liveData = [NSArray arrayWithArray:liveData];
    self.standbyData = [NSArray arrayWithArray:extraData];
    _tableDataLoaded = YES;
}

- (void)setFullContactsPageInviteContext:(NSString *)fullContactsPageInviteContext {
    _fullContactsPageInviteContext = fullContactsPageInviteContext;
    self.inviteFriendsCell.inviteFriendsButton.inviteContext = fullContactsPageInviteContext;
}

- (void)setLiveData:(NSArray *)liveData {
    _liveData = liveData;
    [self updateRecordIDToIndexMapWithTableData:liveData];
}

- (void)updateRecordIDToIndexMapWithTableData:(NSArray *)tableData {
    NSMutableDictionary *reverseMap = [[NSMutableDictionary alloc] init];
    NSInteger i = 0;
    for (MAVEABPerson *person in tableData) {
        [reverseMap setObject:@(i) forKey:@(person.recordID)];
        i++;
    }
    self.recordIDToIndexMap = [NSDictionary dictionaryWithDictionary:reverseMap];
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Last row should be our invite friends cell
    if (self.includeInviteFriendsCell && indexPath.row == [self numberOfRows] - 1) {
        return self.inviteFriendsCell;
    }
    MAVEABPerson *contact = [self _contactAtIndexPath:indexPath];
    if (!contact) {
        return nil;
    }
    MAVESuggestedInviteReusableTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MAVESuggestedInviteReusableCellIdentifier];
    [cell updateForUseWithContact:contact dismissBlock:^{
        [[MaveSDK sharedInstance].APIInterface markSuggestedInviteAsDismissedByUser:contact.hashedRecordID];
        [self _replaceCellForContact:contact afterDelay:0 deleteAnimation:UITableViewRowAnimationLeft];
    } inviteBlock:^{
        [self sendInviteToContact:contact];
        [self _replaceCellForContact:contact afterDelay:0.8 deleteAnimation:UITableViewRowAnimationRight];
        cell.subtitleLabel.text = @" ";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell moveToInviteSentState];
        });
    }];
    if ([self isLastRow:indexPath]) {
        cell.bottomSeparator.hidden = YES;
    }
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.includeInviteFriendsCell && [self isLastRow:indexPath]) {
        return 80;
    } else {
        return self.cellHeight;
    }
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

- (void)_replaceCellForContact:(MAVEABPerson *)contact afterDelay:(CGFloat)delaySeconds deleteAnimation:(UITableViewRowAnimation)deleteAnimation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSNumber *row = [self.recordIDToIndexMap objectForKey:@(contact.recordID)];
        if (!row) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[row integerValue] inSection:self.sectionNumber];

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
        });
    });
}

- (NSInteger)numberOfRows {
    if (!_tableDataLoaded) {
        return 0;
    }
    NSInteger number = [self.liveData count];
    if (self.includeInviteFriendsCell) {
        number += 1;
    }
    return number;
}

- (BOOL)isLastRow:(NSIndexPath *)indexPath {
    return indexPath.section == self.sectionNumber && indexPath.row == [self numberOfRows] - 1;
}

- (void)sendInviteToContact:(MAVEABPerson *)contact {
    contact.isSuggestedContact = YES;
    contact.selectedFromSuggestions = YES;
    contact.selected = YES;

    NSString *message = [MaveSDK sharedInstance].defaultSMSMessageText;
    NSArray *recipients = @[contact];
    [MaveSDK sharedInstance].inviteContext = self.suggestionsCellInviteContext;

    MAVEUserData *user = [MaveSDK sharedInstance].userData;
    [[MaveSDK sharedInstance].APIInterface sendInvitesToRecipients:recipients smsCopy:message senderUserID:user.userID inviteLinkDestinationURL:user.inviteLinkDestinationURL wrapInviteLink:user.wrapInviteLink customData:user.customData completionBlock:^(NSError *error, NSDictionary *responseData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                MAVEErrorLog(@"Error sending invite: %@", error);
                NSString *errorMessage = [NSString stringWithFormat:@"Invite to %@ failed to send. Server was unavailable or internet connection failed", [contact fullName]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invites not sent"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        });
    }];
}

@end
