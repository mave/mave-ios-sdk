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
- (UITextView *)messageTextView {
    return self.wrapperView.aboveTableView.messageTextView;
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
- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.estimatedSectionHeaderHeight = 90;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    [self.tableView registerNib:[UINib nibWithNibName:@"MAVEContactsInvitePageV2Cell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MAVEContactsInvitePageV2CellIdentifier];
}
- (void)setupAboveTableView {
    self.messageTextView.delegate = self;
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
    [self.tableView reloadData];
}

- (void)updateTableDataAnimatedWithSuggestedInvites:(NSArray *)suggestedInvites {

}

- (MAVEABPerson *)tableView:(UITableView *)tableView personForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionIndexLetter = [self.tableSections objectAtIndex:indexPath.section];
    NSArray *rowsInsection = [self.tableData objectForKey:sectionIndexLetter];
    return (MAVEABPerson *)[rowsInsection objectAtIndex:indexPath.row];
}


#pragma mark - TextViewDelegate methods (for message field)
- (void)textViewDidChange:(UITextView *)textView {
    [self.wrapperView layoutSubviews];
}

#pragma mark - Table sections layout
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tableSections count];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionKey = [self.tableSections objectAtIndex:section];
    NSArray *rowsInSection = [self.tableData valueForKey:sectionKey];
    return [rowsInSection count];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
    [cell updateWithInfoForPerson:person];
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
