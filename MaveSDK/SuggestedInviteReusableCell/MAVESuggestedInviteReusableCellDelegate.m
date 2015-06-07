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
    MAVESuggestedInviteReusableTableViewCell *tmpCell = [[MAVESuggestedInviteReusableTableViewCell alloc] init];
    self.cellHeight = [tmpCell cellHeight];
}

- (void)getSuggestionsAndLoadAsynchronously {
    [[MaveSDK sharedInstance] getSuggestedInvites:^(NSArray *suggestedInvites) {
        [self _loadSuggestedInvites:suggestedInvites];
        NSLog(@"got %@ suggestions", @([suggestedInvites count]));
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
}

- (MAVESuggestedInviteReusableTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEABPerson *contact = [self _contactAtIndexPath:indexPath];
    if (!contact) {
        return nil;
    }
    MAVESuggestedInviteReusableTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MAVESuggestedInviteReusableCellIdentifier];
    [cell updateForUseWithContact:contact];
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


- (NSInteger)numberOfRows {
    return [self.liveData count];
}

@end
