//
//  MAVEContactsInvitePageV2ViewController.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import <objc/runtime.h>
#import "MAVEContactsInvitePageV2ViewController.h"
#import "MAVEContactsInvitePageV2TableHeaderView.h"
#import "MAVEContactsInvitePageV2TableViewCell2.h"
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVEABUtils.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVEABTableViewController.h"
#import "MAVEInviteTableSectionHeaderView.h"

const char MAVESendFailedAlertViewDataKey;
NSString * const MAVEContactsInvitePageV2CellIdentifier = @"personCell";

@implementation MAVEContactsInvitePageV2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Helpers for accessing deeply nested objects
- (UITableView *)tableView {
    return self.wrapperView.tableView;
}
- (UITableView *)searchTableView {
    return self.wrapperView.searchTableView;
}
- (UITextView *)messageTextView {
    return self.wrapperView.aboveTableView.messageTextView;
}
- (MAVESearchBar *)searchBar {
    return self.wrapperView.aboveTableView.searchBar;
}

- (void)loadView {
    if (self.navigationItem) {
        self.navigationItem.title = @"Send SMS Separately";
    }
    self.wrapperView = [[MAVEContactsInvitePageV2TableWrapperView alloc] init];
    self.suggestionsSectionHeaderView = [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:@"Suggestions" sectionIsWaiting:YES];
    [self setupAboveTableView];
    [self setupTableView];
    self.view = self.wrapperView;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self loadContactsIntoTableOrSwitchToFallbackBasedOnPermissions];
}
- (void)setupAboveTableView {
    self.messageTextView.delegate = self;
    self.searchBar.delegate = self;
    self.searchBar.returnKeyType = UIReturnKeyDone;
}
- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.estimatedSectionHeaderHeight = 20;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.estimatedRowHeight = 50;
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;


//    NSBundle *bundle = [MAVEBuiltinUIElementUtils bundleForMave];
//    [self.tableView registerNib:[UINib nibWithNibName:@"MAVEContactsInvitePageV2Cell" bundle:bundle] forCellReuseIdentifier:MAVEContactsInvitePageV2CellIdentifier];
    [self.tableView registerClass:[MAVEContactsInvitePageV2TableViewCell2 class] forCellReuseIdentifier:MAVEContactsInvitePageV2CellIdentifier];
}



#pragma mark - Loading Content into table
- (void)loadContactsIntoTableOrSwitchToFallbackBasedOnPermissions {
    [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock: ^(NSArray *contacts) {
        // Permission denied
        if ([contacts count] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MaveSDK sharedInstance].invitePageChooser replaceActiveViewControllerWithFallbackPage];
            });
            // Permission granted
        } else {
            NSDictionary *indexedContactsToRenderNow;
            BOOL updateSuggestionsWhenReady = NO;
            [MAVEInvitePageViewController buildContactsToUseAtPageRender:&indexedContactsToRenderNow
                                              addSuggestedLaterWhenReady:&updateSuggestionsWhenReady
                                                        fromContactsList:contacts];
            if (updateSuggestionsWhenReady) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSArray *suggestions = [[MaveSDK sharedInstance] suggestedInvitesWithFullContactsList:contacts delay:10];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateTableDataAnimatedWithSuggestedInvites:suggestions];

                    });
                });
            }

            // Render the contacts we have now regardless
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTableData:indexedContactsToRenderNow];

                // Only if permission was granted should we log that we displayed
                // the invite page with an address book list
                [[MaveSDK sharedInstance].APIInterface trackInvitePageOpenForPageType:MAVEInvitePageTypeContactList];
            });
        }
    }];
}

#pragma mark - Table data person records
- (void)updateTableData:(NSDictionary *)tableData {
    [self updateTableDataWithoutReloading:tableData];

    // if there are definitely no suggestions, the section won't exist in table data.
    // if section does exist and is empty, it should be pending (which is the default
    // state of the suggestions section header view).
    // if it's not empty, stop the pending dots
    NSArray *suggestions = [tableData objectForKey:MAVESuggestedInvitesTableDataKey];
    if (suggestions && [suggestions count] != 0) {
        [self.suggestionsSectionHeaderView stopWaiting];
    }

    [self.tableView reloadData];
}
- (void)updateTableDataAnimatedWithSuggestedInvites:(NSArray *)suggestedInvites {
    // Update the table data without telling the table to reload
    NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithDictionary:self.tableData];
    if ([suggestedInvites count] == 0) {
        // no suggested invites, remove the section from data source and reload
        [newData removeObjectForKey:MAVESuggestedInvitesTableDataKey];
        [self updateTableData:[NSDictionary dictionaryWithDictionary:newData]];
        return;
    } else {
        // Add the suggested invites to data source before animating them in
        [newData setObject:suggestedInvites forKey:MAVESuggestedInvitesTableDataKey];
        [self updateTableDataWithoutReloading:[NSDictionary dictionaryWithDictionary:newData]];
    }

    // Animate in the new rows
    NSUInteger indexOfSuggested = [self.tableSections indexOfObject:MAVESuggestedInvitesTableDataKey];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:[suggestedInvites count]];
    for (NSInteger rowNumber = 0; rowNumber < [suggestedInvites count]; ++rowNumber) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:rowNumber inSection:indexOfSuggested]];
    }

    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.suggestionsSectionHeaderView stopWaiting];
}
- (void)updateTableDataWithoutReloading:(NSDictionary *)tableData {
    self.tableData = tableData;
    self.tableSections = [[tableData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.allContacts = [self enumerateAllContacts];
    [self updatePersonToIndexPathsIndex];
}
- (NSArray *)enumerateAllContacts {
    NSMutableArray *mutableAllPeople = [NSMutableArray array];
    NSMutableSet *mutableAllPeopleUnique = [[NSMutableSet alloc] init];
    for (NSString *sectionKey in self.tableSections) {
        NSArray *section = [self.tableData objectForKey:sectionKey];
        for (MAVEABPerson *person in section) {
            if (![mutableAllPeopleUnique containsObject:person]) {
                [mutableAllPeople addObject:person];
                [mutableAllPeopleUnique addObject:person];
            }
        }
    }
    return [NSArray arrayWithArray:mutableAllPeople];
}
// Build a reverse index from people to the index paths they're found at in the table
// The data structure is is an dictionary mapping an NSNumber (person recordID) to an NSArray of
// NSIndexPaths.
// NB: a person can be found at multiple rows in a table which is why we map to an array of index paths
- (void)updatePersonToIndexPathsIndex {
    NSNumber *personKey;
    NSIndexPath *idxPath; NSInteger sectionIdx = 0, rowIdx = 0;
    NSMutableDictionary *index = [[NSMutableDictionary alloc] init];
    for (NSString *sectionKey in self.tableSections) {
        rowIdx = 0;
        for (MAVEABPerson *person in [self.tableData objectForKey:sectionKey]) {
            personKey = [NSNumber numberWithInteger:person.recordID];
            idxPath = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
            if (![index objectForKey:personKey]) {
                [index setObject:[[NSMutableArray alloc] init] forKey:personKey];
            }
            [[index objectForKey:personKey] addObject:idxPath];
            rowIdx++;
        }
        sectionIdx++;
    }
    self.personToIndexPathsIndex = index;
}
- (MAVEABPerson *)tableView:(UITableView *)tableView personForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.searchTableView]) {
        if ([self.searchTableData count] == 0) {
            return nil;
        } else {
            return [self.searchTableData objectAtIndex:indexPath.row];
        }
    }
    NSString *sectionIndexLetter = [self.tableSections objectAtIndex:indexPath.section];
    NSArray *rowsInSection = [self.tableData objectForKey:sectionIndexLetter];
    return (MAVEABPerson *)[rowsInSection objectAtIndex:indexPath.row];
}
// Returns an array of nsindexpaths, guarenteed to have at least one item in the array.
// If person is not in the table it returns an array with the index path of the top
// of the table
- (NSArray *)indexPathsOnMainTableViewForPerson:(MAVEABPerson *)person {
    NSArray *indexPaths;
    if (person.recordID > 0) {
        NSNumber *recordID = [NSNumber numberWithInteger:person.recordID];
        indexPaths = [self.personToIndexPathsIndex objectForKey:recordID];
    }
    if (!indexPaths || [indexPaths count] == 0) {
        indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    return indexPaths;
}


#pragma mark - TextViewDelegate methods (only for message field)
- (void)textViewDidChange:(UITextView *)textView {
    [self.wrapperView layoutSubviews];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    // Set some limit so people don't go crazy with long sms messages
    if ([newText length] > 300) {
        return NO;
    }
    return YES;
}

#pragma mark - Search related (UITextFieldDelegate methods)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newText isEqualToString:@"\n"]) {
        [self.searchBar endEditing:YES];
        return NO;
    }
    if ([newText length] > 0) {
        self.tableView.hidden = YES;
        self.searchTableView.hidden = NO;
        [self searchAndUpdateSearchTableView:newText];
    } else {
        self.tableView.hidden = NO;
        self.searchTableView.hidden = YES;
    }
    return YES;
}
- (void)searchAndUpdateSearchTableView:(NSString *)searchText {
    self.searchTableData = [MAVEABTableViewController searchContacts:[self allContacts] withText:searchText];
    [self.searchTableView reloadData];
}
// Must call this method in the main thread
- (void)jumpToMainTableRowForPerson:(MAVEABPerson *)person {
    self.searchBar.text = @"";
    [self.searchBar endEditing:YES];
    self.searchTableView.hidden = YES;
    self.tableView.hidden = NO;
    NSIndexPath *indexOnMainTable = [[self indexPathsOnMainTableViewForPerson:person] objectAtIndex:0];
    if (indexOnMainTable) {
        [self.tableView scrollToRowAtIndexPath:indexOnMainTable atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - Table sections layout
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.searchTableView]) {
        return 1;
    }
    return [self.tableSections count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchTableView]) {
        NSInteger numberRows = [self.searchTableData count];
        if (numberRows == 0) { numberRows = 1; }
        return numberRows;
    }
    NSString *sectionKey = [self.tableSections objectAtIndex:section];
    NSArray *rowsInSection = [self.tableData valueForKey:sectionKey];
    return [rowsInSection count];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchTableView]) {
        return [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:@"Search Results" sectionIsWaiting:NO];
    }
    NSString *sectionKey = [self.tableSections objectAtIndex:section];
    if ([sectionKey isEqualToString:MAVESuggestedInvitesTableDataKey]) {
        return self.suggestionsSectionHeaderView;
    }
    return [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:sectionKey sectionIsWaiting:NO];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UIView *sectionHeaderView = [self tableView:tableView viewForHeaderInSection:section];
    return sectionHeaderView.frame.size.height;
}

# pragma mark - Table cell layout
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEContactsInvitePageV2TableViewCell2 *cell =  [self.tableView dequeueReusableCellWithIdentifier:MAVEContactsInvitePageV2CellIdentifier];
    cell.delegateController = self;
    MAVEABPerson *person = [self tableView:tableView personForRowAtIndexPath:indexPath];
    if (!person) {
        [cell updateWithInfoForNoPersonFound];
    } else {
        [cell updateWithInfoForPerson:person];
    }
    return cell;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 50;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do nothing, rows are not selectable
}
#pragma mark - Table side index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return self.tableSections;
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.tableView) {
        return index;
    } else {
        return -1;
    }
}

#pragma mark - Send invites
- (void)sendInviteToPerson:(MAVEABPerson *)person sendButton:(UIButton *)sendButton {
    NSString *phoneToinvite = [person bestPhone];
    if (!phoneToinvite) {
        return;
    }
    NSArray *phonesToInvite = @[phoneToinvite];
    NSArray *peopleToinvite = @[person];
    NSString *message = self.messageTextView.text;

    // mark as "Sending..." status, and use semaphore to make sure it doesn't do an ugly flash
    // on Sending and go immediately to sent, set an artificial delay if send completes immediately
    dispatch_semaphore_t sendingStatusSema = dispatch_semaphore_create(0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_semaphore_signal(sendingStatusSema);
    });
    [UIView transitionWithView:sendButton
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ sendButton.selected = YES; }
                    completion:nil];

    // end editing to close the keyboard if it's open
    [self.messageTextView endEditing:YES];

    MaveSDK *mave = [MaveSDK sharedInstance];
    MAVEAPIInterface *apiInterface = mave.APIInterface;
    [apiInterface sendInvitesWithRecipientPhoneNumbers:phonesToInvite
                               recipientContactRecords:peopleToinvite
                                               message:message
                                                userId:mave.userData.userID
                              inviteLinkDestinationURL:mave.userData.inviteLinkDestinationURL
                                        wrapInviteLink:mave.userData.wrapInviteLink
                                            customData:mave.userData.customData
                                       completionBlock:^(NSError *error, NSDictionary *responseData) {
       if (error != nil) {
           MAVEDebugLog(@"Invites failed to send, error: %@, response: %@",
                        error, responseData);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSendFailureErrorAndResetPerson:person];
            });
       } else {
           MAVEInfoLog(@"Sent invite to %@!", person.fullName);
           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
               dispatch_semaphore_wait(sendingStatusSema, DISPATCH_TIME_FOREVER);
               dispatch_async(dispatch_get_main_queue(), ^{
                   person.selected = YES;
                   [self.tableView reloadData];
                   // if search table view is active, switch back to non-search table view
                   if (!self.searchTableView.hidden) {
                       [self jumpToMainTableRowForPerson:person];
                   }
               });
           });
       }
    }];
}

- (void)showSendFailureErrorAndResetPerson:(MAVEABPerson *)person {
    NSString *message = [NSString stringWithFormat:@"Invite to %@ failed.\nServer was unavailable or internet connection failed.\nTry again later.", person.fullName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invite not sent"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    objc_setAssociatedObject(alert, &MAVESendFailedAlertViewDataKey, person, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alert show];
}
// Only alert view is the send failure error, and only button on alert is cancel
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    MAVEABPerson *person = objc_getAssociatedObject(alertView, &MAVESendFailedAlertViewDataKey);
    if (person) {
        person.selected = NO;
        [self.tableView reloadData];
        [self jumpToMainTableRowForPerson:person];
    }
}


@end
