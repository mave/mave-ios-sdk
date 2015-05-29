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
    self.wrapperView.bigSendButtonHeightConstraint.constant = 0;

    self.dataManager = [[MAVEContactsInvitePageDataManager alloc] init];
    self.selectedPeopleIndex = [[NSMutableSet alloc] init];
    self.selectedContactIdentifiersIndex = [[NSMutableSet alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[MAVEContactsInvitePageV3Cell class]
           forCellReuseIdentifier:MAVEContactsInvitePageV3CellIdentifier];

    self.sampleCell = [[MAVEContactsInvitePageV3Cell alloc] init];

    [self loadContactsData];
}

- (void)dealloc {
    NSLog(@"table view dealloced");
}

- (void)loadView {
    MAVEContactsInvitePageV3TableWrapperView *wrapperView = [[MAVEContactsInvitePageV3TableWrapperView alloc] init];
    self.wrapperView = wrapperView;
    self.view = wrapperView;
}
- (UITableView *)tableView {
    return self.wrapperView.tableView;
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
- (MAVEABPerson *)personAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataManager personAtMainTableIndexPath:indexPath];
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
    [self.wrapperView updateBigSendButtonHeightExpanded:(numSelected > 0)];
    [self.wrapperView.bigSendButton updateButtonTextNumberToSend:[self.selectedContactIdentifiersIndex count]];
}

#pragma mark - Table View Data Source & Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataManager numberOfSectionsInMainTable];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.dataManager sectionIndexesForMainTable];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataManager numberOfRowsInMainTableSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *text = [[self.dataManager sectionIndexesForMainTable] objectAtIndex:section];
    return [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:text sectionIsWaiting:NO];
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEABPerson *person = [self personAtIndexPath:indexPath];
    NSInteger numberContactInfoRecords = person.selected ? [[person allContactIdentifiers] count] : 0;
    return [self.sampleCell heightGivenNumberOfContactInfoRecords:numberContactInfoRecords];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEContactsInvitePageV3Cell *cell = [self.tableView dequeueReusableCellWithIdentifier:MAVEContactsInvitePageV3CellIdentifier];

    MAVEABPerson *person = [self personAtIndexPath:indexPath];
    [cell updateForReuseWithPerson:person];
    __weak MAVEContactsInvitePageV3ViewController *weakSelf = self;
    cell.contactIdentifiersSelectedDidUpdateBlock = ^void(MAVEABPerson *person) {
        [weakSelf updateToReflectPersonSelectedStatus:person];
    };
    return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEABPerson *person = [self personAtIndexPath:indexPath];
    person.selected = !person.selected;
    [self updateToReflectPersonSelectedStatus:person];

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
