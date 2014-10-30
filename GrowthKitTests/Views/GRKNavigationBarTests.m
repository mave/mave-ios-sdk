//
//  GRKNavigationBarTests.m
//  GrowthKit
//
//  Created by Danny Cosson on 10/30/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "GrowthKit.h"
#import "GRKInvitePageViewController.h"
#import "GRKDisplayOptionsFactory.h"


@interface GRKNavigationBarTests : XCTestCase

@end

// Tests for the navigation bar setup at the top of the invite page
@implementation GRKNavigationBarTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNavBarSetup {
    [GrowthKit setupSharedInstanceWithApplicationID:@"appid1"];
    GRKDisplayOptions *opts = [GRKDisplayOptionsFactory generateDisplayOptions];
    [GrowthKit sharedInstance].displayOptions = opts;
    
    GRKInvitePageViewController *vc = [[GRKInvitePageViewController alloc] init];
    UINavigationController *sampleNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    XCTAssertNotNil(sampleNavigationController);
    [vc setupNavigationBar];
    XCTAssertEqualObjects(vc.navigationItem.title, @"Invite Friends");
    XCTAssertEqualObjects(vc.navigationController.navigationBar.barTintColor,
                          opts.navigationBarBackgroundColor);
    NSDictionary *expectedTitleTextAttrs = @{
        NSForegroundColorAttributeName: opts.navigationBarTitleColor,
        NSFontAttributeName: opts.navigationBarTitleFont,
        };
    XCTAssertEqualObjects(vc.navigationController.navigationBar.titleTextAttributes, expectedTitleTextAttrs);
}

@end
