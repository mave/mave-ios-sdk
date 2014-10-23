//
//  SideDrawerController.m
//  GrowthKit
//
//  Created by Danny Cosson on 10/22/14.
//
//

#import "SideDrawerController.h"

#import "GrowthKit.h"
#import "RootDrawerController.h"
#import "InvitePageDelegate.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

@interface SideDrawerController ()

@end

@implementation SideDrawerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentIndex = 0;
    self.sideDrawerMenuItemNames = @[@"Home", @"Invite"];
    self.sideDrawerMenuItemIdentifiers = @[kDrawerHomeController, kDrawerInviteController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentIndex == indexPath.row) {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        return;
    }

    self.currentIndex = indexPath.row;
    NSString *controllerIdentifier = self.sideDrawerMenuItemIdentifiers[indexPath.row];
    UIViewController * centerViewController;
    if ([controllerIdentifier isEqualToString:kDrawerInviteController]) {
        InvitePageDelegate *invitePageDelegate = [[InvitePageDelegate alloc] init];
        invitePageDelegate.mm_drawerController = self.mm_drawerController;
        centerViewController = [[GrowthKit sharedInstance] invitePageViewControllerWithDelegate:invitePageDelegate];
    } else {
        centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:controllerIdentifier];
    }
    [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sideDrawerMenuItemNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideDrawerCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.sideDrawerMenuItemNames objectAtIndex:indexPath.row];
    return cell;
}

@end
