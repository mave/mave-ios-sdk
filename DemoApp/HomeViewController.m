//
//  ViewController.m
//  DemoApp
//
//  Created by dannycosson on 10/10/14.
//
//

#import "HomeViewController.h"

#import <UIKit/UIKit.h>

#import "MaveSDK.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"


@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
//    UILabel *label;
//    self.view.backgroundColor = [UIColor greenColor];
//    for (int i = 0; i < [self.view.subviews count]; i++) {
//        if ([self.view.subviews[i] class] == [UILabel class]) {
//            label = self.view.subviews[i];
//            label.textColor = [UIColor redColor];
//        }
//    }
}

- (IBAction)presentInvitePageAsModal:(id)sender {
    // Reset bar button item back to normal "Cancel"
    UIBarButtonItem *bbi =
        [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    [MaveSDK sharedInstance].displayOptions.navigationBarCancelButton = bbi;


    // Present Modally

//    MaveSDK *mave = [MaveSDK sharedInstance];
//    [mave presentInvitePageModallyWithBlock:^(UIViewController *inviteController) {
//        [self presentViewController:inviteController animated:YES completion:nil];
//    } dismissBlock:^(UIViewController *controller, NSUInteger numberOfInvitesSent) {
//        [controller dismissViewControllerAnimated:YES completion:nil];
//    } inviteContext:@"home-page-modal"];


    // Present Push

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *afterInvitesPage = [storyboard
                                          instantiateViewControllerWithIdentifier:@"PushAfterInvitesPage"];
    MaveSDK *mave = [MaveSDK sharedInstance];

    // Set a custom back button
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
//    backButton.title = @"dat @$$ up";
//    mave.displayOptions.navigationBarBackButton = backButton;

    [mave presentInvitePagePushWithBlock:^(UIViewController *inviteController) {

        [self.navigationController pushViewController:inviteController animated:YES];
    } forwardBlock:^(UIViewController *controller, NSUInteger numberOfInvitesSent) {

        [controller.navigationController pushViewController:afterInvitesPage animated:YES];
    } backBlock:^(UIViewController *controller, NSUInteger numberOfInvitesSent) {

        [controller.navigationController popViewControllerAnimated:YES];
    } inviteContext:@"home-page-pushed"];

}

// Methods to present this home view in the drawer
- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}


- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


@end
