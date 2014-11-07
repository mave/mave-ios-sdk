//
//  SideDrawerController.m
//  MaveSDK
//
//  Created by Danny Cosson on 10/22/14.
//
//

#import "SideDrawerController.h"

#import "MaveSDK.h"
#import "RootDrawerController.h"
#import "SideDrawerInvitePageDelegate.h"
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
        SideDrawerInvitePageDelegate *invitePageDelegate = [[SideDrawerInvitePageDelegate alloc] initWithDrawerController:self.mm_drawerController];
        NSError *err;
        centerViewController = [[MaveSDK sharedInstance] invitePageViewControllerWithDelegate:invitePageDelegate
                                                                        defaultSMSMessageText:@"Join me on Mave!"
                                                                                        error:&err];
        if (err) { // Invite view not initialized properly, just leave drawer open
            return;
        }
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
