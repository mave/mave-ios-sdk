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

    // Still presenting the older way
    NSError *setupError;
    NSString *defaultMessage = @"Join me on DEMO APP!";
    UIViewController *inviteController = [[MaveSDK sharedInstance]
        invitePageWithDefaultMessage:defaultMessage
                          setupError:&setupError
                      dismissalBlock:^(UIViewController *viewController,
                                       NSUInteger numberOfInvitesSent) {
                          [viewController dismissViewControllerAnimated:YES completion:nil];
    }];
    if (!setupError) {
        [self presentViewController:inviteController animated:YES completion:nil];
    }
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