//
//  MAVEContactsInvitePageV3ViewController.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/21/15.
//
//

#import "MAVEContactsInvitePageV3ViewController.h"
#import "MAVEContactsInvitePageV3TableWrapperView.h"
#import "MAVEContactsInvitePageV3Cell.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVEInvitePageViewController.h"

NSString * const MAVEContactsInvitePageV3CellIdentifier = @"MAVEContactsInvitePageV3CellIdentifier";

@interface MAVEContactsInvitePageV3ViewController ()

@end

@implementation MAVEContactsInvitePageV3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[MAVEContactsInvitePageV3Cell class]
           forCellReuseIdentifier:MAVEContactsInvitePageV3CellIdentifier];

    self.sampleCell = [[MAVEContactsInvitePageV3Cell alloc] init];

    [self loadContactsData];
}

- (void)loadView {
    self.view = [[MAVEContactsInvitePageV3TableWrapperView alloc] init];
}
- (UITableView *)tableView {
    return ((MAVEContactsInvitePageV3TableWrapperView *)self.view).tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Loading Contacts Data
- (void)loadContactsData {
    [MAVEABPermissionPromptHandler promptForContactsWithCompletionBlock: ^(NSArray *contacts) {

        NSDictionary *indexedContactsToRenderNow;
        BOOL updateSuggestionsWhenReady = NO;
        [MAVEInvitePageViewController buildContactsToUseAtPageRender:&indexedContactsToRenderNow
                                          addSuggestedLaterWhenReady:&updateSuggestionsWhenReady
                                                    fromContactsList:contacts];

        self.tableData = indexedContactsToRenderNow;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}
- (MAVEABPerson *)personAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [[self sectionIndexTitlesForTableView:nil] objectAtIndex:indexPath.section];
    NSArray *dataInSection = [self.tableData objectForKey:sectionKey];
    return [dataInSection objectAtIndex:indexPath.row];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.tableData allKeys];
}

#pragma mark - Table View Data Source & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.tableData allKeys] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionKey = [[self sectionIndexTitlesForTableView:tableView] objectAtIndex:section];
    NSArray *dataInSection = [self.tableData objectForKey:sectionKey];
    return [dataInSection count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *text = @"Foo";
    return [[MAVEInviteTableSectionHeaderView alloc] initWithLabelText:text sectionIsWaiting:NO];
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEABPerson *person = [self personAtIndexPath:indexPath];
    return [self.sampleCell heightGivenNumberOfContactInfoRecords:[person.phoneNumbers count]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEContactsInvitePageV3Cell *cell = [tableView dequeueReusableCellWithIdentifier:MAVEContactsInvitePageV3CellIdentifier];
    MAVEABPerson *person = [self personAtIndexPath:indexPath];
    [cell updateForReuseWithPerson:person];
    return (UITableViewCell *)cell;
}

@end
