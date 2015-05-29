//
//  MAVEContactsInvitePageV3ViewController.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import "MAVEContactsInvitePageV3ViewController.h"
#import "MAVEContactsInvitePageV3Cell.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVEInvitePageViewController.h"

NSString * const MAVEContactsInvitePageV3CellIdentifier = @"MAVEContactsInvitePageV3CellIdentifier";

@interface MAVEContactsInvitePageV3ViewController ()

@end

@implementation MAVEContactsInvitePageV3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;

    self.dataManager = [[MAVEContactsInvitePageDataManager alloc] init];
    self.searchManager = [[MAVEContactsInvitePageSearchManager alloc] initWithDataManager:self.dataManager andSearchTable:self.searchTableView];
    self.wrapperView.searchBar.delegate = self.searchManager;
    self.selectedPeopleIndex = [[NSMutableSet alloc] init];
    self.selectedContactIdentifiersIndex = [[NSMutableSet alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[MAVEContactsInvitePageV3Cell class]
           forCellReuseIdentifier:MAVEContactsInvitePageV3CellIdentifier];
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    [self.searchTableView registerClass:[MAVEContactsInvitePageV3Cell class] forCellReuseIdentifier:MAVEContactsInvitePageV3CellIdentifier];
    self.sampleCell = [[MAVEContactsInvitePageV3Cell alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];

    [self loadContactsData];
}

- (void)dealloc {
    NSLog(@"table view dealloced");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGFloat fullViewHeight = self.view.frame.origin.y + self.view.frame.size.height;
    CGRect newKeyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat neededBottomPadding = MAX(fullViewHeight - newKeyboardFrame.origin.y, 0);
    self.wrapperView.extraBottomPaddingHeightConstraint.constant = neededBottomPadding;
    [self.wrapperView layoutIfNeeded];
}

- (void)loadView {
    MAVEContactsInvitePageV3TableWrapperView *wrapperView = [[MAVEContactsInvitePageV3TableWrapperView alloc] init];
    self.wrapperView = wrapperView;
    self.view = wrapperView;
}
- (UITableView *)tableView {
    return self.wrapperView.tableView;
}
- (UITableView *)searchTableView {
    return self.wrapperView.searchTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Loading Contacts Data
- (void)loadContactsData {
    [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock: ^(NSArray *contacts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataManager updateWithContacts:contacts ifNecessaryAsyncSuggestionsBlock:nil];
            [self.tableView reloadData];
        });
    }];
}
-(void)updateToReflectPersonSelectedStatus:(MAVEABPerson *)person {
    if (person.selected) {
        [self.selectedPeopleIndex addObject:person];
        for (id rec in person.allContactIdentifiers) {
            [self.selectedContactIdentifiersIndex removeObject:rec];
        }
        for (id rec in person.selectedContactIdentifiers) {
            [self.selectedContactIdentifiersIndex addObject:rec];
        }
    } else {
        [self.selectedPeopleIndex removeObject:person];
        for (id rec in person.allContactIdentifiers) {
            [self.selectedContactIdentifiersIndex removeObject:rec];
        }
    }
    NSUInteger numSelected = [self.selectedContactIdentifiersIndex count];
    [self.wrapperView updateBigSendButtonHeightExpanded:(numSelected > 0) animated:YES];
    [self.wrapperView.bigSendButton updateButtonTextNumberToSend:[self.selectedContactIdentifiersIndex count]];
}

#pragma mark - Table View Data Source & Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.searchTableView]) {
        return 1;
    } else {
        return [self.dataManager numberOfSectionsInMainTable];
    }
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.searchTableView]) {
        return nil;
    } else {
        return [self.dataManager sectionIndexesForMainTable];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchTableView]) {
//        return MAX([[self.dataManager searchTableData] count], 1);
        return [[self.dataManager searchTableData] count];
    } else {
        return [self.dataManager numberOfRowsInMainTableSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *text;
    if ([tableView isEqual:self.searchTableView]) {
        text = @"Search Results";
    } else {
        text = [[self.dataManager sectionIndexesForMainTable] objectAtIndex:section];
    }
    return [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:text sectionIsWaiting:NO];
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEABPerson *person;
    if ([tableView isEqual:self.searchTableView]) {
        person = [self.dataManager personAtSearchTableIndexPath:indexPath];
    } else {
        person = [self.dataManager personAtMainTableIndexPath:indexPath];
    }
    NSInteger numberContactInfoRecords = person.selected ? [[person allContactIdentifiers] count] : 0;
    return [self.sampleCell heightGivenNumberOfContactInfoRecords:numberContactInfoRecords];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEContactsInvitePageV3Cell *cell = [tableView dequeueReusableCellWithIdentifier:MAVEContactsInvitePageV3CellIdentifier];

    MAVEABPerson *person;
    if ([tableView isEqual:self.searchTableView]) {
        person = [self.dataManager personAtSearchTableIndexPath:indexPath];
    } else {
        person = [self.dataManager personAtMainTableIndexPath:indexPath];
    }

    [cell updateForReuseWithPerson:person];
    __weak MAVEContactsInvitePageV3ViewController *weakSelf = self;
    cell.contactIdentifiersSelectedDidUpdateBlock = ^void(MAVEABPerson *person) {
        [weakSelf updateToReflectPersonSelectedStatus:person];
    };
    return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEABPerson *person;
    if ([tableView isEqual:self.searchTableView]) {
        person = [self.dataManager personAtSearchTableIndexPath:indexPath];
    } else {
        person = [self.dataManager personAtMainTableIndexPath:indexPath];
    }
    person.selected = !person.selected;
    [self updateToReflectPersonSelectedStatus:person];

    [tableView beginUpdates];
    [tableView endUpdates];
}

@end
