//
//  MAVENavigationBarTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 10/30/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MaveSDK.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEDisplayOptionsFactory.h"


@interface MAVENavigationBarTests : XCTestCase

@end

// Tests for the navigation bar setup at the top of the invite page
@implementation MAVENavigationBarTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNavBarSetup {
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];
    MAVEDisplayOptions *opts = [MAVEDisplayOptionsFactory generateDisplayOptions];
    [MaveSDK sharedInstance].displayOptions = opts;
    
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
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
