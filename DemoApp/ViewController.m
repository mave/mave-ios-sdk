//
//  ViewController.m
//  DemoApp
//
//  Created by dannycosson on 10/10/14.
//
//

#import "ViewController.h"
#import "GrowthKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openInvitePage:(id)sender {
    [[GrowthKit sharedInstance] presentInvitePage:self];
}

@end
