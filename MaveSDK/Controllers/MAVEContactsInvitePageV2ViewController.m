//
//  MAVEContactsInvitePageV2ViewController.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/8/15.
//
//

#import "MAVEContactsInvitePageV2ViewController.h"
#import "MAVEContactsInvitePageV2TableHeaderView.h"
#import "MAVEContactsInvitePageV2TableViewCell2.h"
#import "MaveSDK.h"
#import "MAVEABUtils.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVEABTableViewController.h"
#import "MAVEInviteTableSectionHeaderView.h"

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
    [self setupAboveTableView];
    [self setupTableView];
    self.view = self.wrapperView;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self loadContactsIntoTableOrSwitchToFallbackBasedOnPermissions];
}
- (void)setupAboveTableView {
    self.messageTextView.delegate = self;
    self.searchBar.delegate = self;
}
- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.estimatedSectionHeaderHeight = 90;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;

    [self.tableView registerNib:[UINib nibWithNibName:@"MAVEContactsInvitePageV2Cell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MAVEContactsInvitePageV2CellIdentifier];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *indexedContacts = [MAVEABUtils indexABPersonArrayForTableSections:contacts];
                [self updateTableData:indexedContacts];

                // Only if permission was granted should we log that we displayed
                // the invite page with an address book list
                [[MaveSDK sharedInstance].APIInterface trackInvitePageOpenForPageType:MAVEInvitePageTypeContactList];
            });
        }
    }];
}
- (void)updateTableData:(NSDictionary *)tableData {
    self.tableData = tableData;
    self.tableSections = [[tableData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.allContacts = [self enumerateAllContacts];
    [self.tableView reloadData];
}
- (void)updateTableDataAnimatedWithSuggestedInvites:(NSArray *)suggestedInvites {

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


#pragma mark - TextViewDelegate methods (only for message field)
- (void)textViewDidChange:(UITextView *)textView {
    [self.wrapperView layoutSubviews];
}

#pragma mark - TextFieldDelegate methods (only for search bar)
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
    return [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:sectionKey sectionIsWaiting:NO];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UIView *sectionHeaderView = [self tableView:tableView viewForHeaderInSection:section];
    return sectionHeaderView.frame.size.height;
}

# pragma mark - Table cell layout
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEContactsInvitePageV2TableViewCell2 *cell =  [self.tableView dequeueReusableCellWithIdentifier:MAVEContactsInvitePageV2CellIdentifier];
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


@end
