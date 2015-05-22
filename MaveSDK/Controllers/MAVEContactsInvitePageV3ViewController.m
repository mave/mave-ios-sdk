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

#pragma mark - Table View Data Source & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MAVEContactsInvitePageV3Cell *cell = [tableView dequeueReusableCellWithIdentifier:MAVEContactsInvitePageV3CellIdentifier];
    return (UITableViewCell *)cell;
}



@end
