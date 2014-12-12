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
        // Style the bar button for drawer controller use
        MMDrawerBarButtonItem *bbi = [[MMDrawerBarButtonItem alloc] initWithTarget:nil action:nil];
        [MaveSDK sharedInstance].displayOptions.navigationBarCancelButton = bbi;

        NSError *setupError;
        NSString *defaultMessage = @"Join me on DEMO APP! it's a fun way to do some things blah blah blah ok cool that's nice. Also invite codes.";
        centerViewController = [[MaveSDK sharedInstance]
            invitePageWithDefaultMessage:defaultMessage
                              setupError:&setupError
                          dismissalBlock:^(UIViewController *viewController,
                                           NSUInteger numberOfInvitesSent) {
                              NSLog(@"in dismissal block");
                              [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        }];
        if (setupError) {
            [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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
