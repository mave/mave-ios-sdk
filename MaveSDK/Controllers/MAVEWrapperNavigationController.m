//
//  MAVEWrapperNavigationController.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/31/15.
//
//

#import "MAVEWrapperNavigationController.h"
#import "MaveSDK.h"

@interface MAVEWrapperNavigationController ()

@end

@implementation MAVEWrapperNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [MaveSDK sharedInstance].displayOptions.statusBarStyle;
}

@end
