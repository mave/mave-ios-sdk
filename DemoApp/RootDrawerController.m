//
//  RootViewController.m
//  Mave
//
//  Created by Danny Cosson on 10/22/14.
//
//

#import "RootDrawerController.h"
#import "MMDrawerController.h"

NSString * const kDrawerSideController = @"DRAWER_SIDE_CONTROLLER";
NSString * const kDrawerHomeController = @"DRAWER_HOME_CONTROLLER";
NSString * const kDrawerInviteController = @"DRAWER_INVITE_CONTROLLER";

@implementation RootDrawerController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDrawers];
}

- (void)setupDrawers {
    UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:kDrawerHomeController];
    UIViewController *leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:kDrawerSideController];
    [self setCenterViewController:centerViewController];
    [self setLeftDrawerViewController:leftViewController];
}

@end