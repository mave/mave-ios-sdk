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
    MAVEDisplayOptions *displayOpts = [MAVEDisplayOptionsFactory generateDisplayOptions];
    [MaveSDK sharedInstance].displayOptions = displayOpts;
    
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    UINavigationController *sampleNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    XCTAssertNotNil(sampleNavigationController);
    [vc setupNavigationBar];
    XCTAssertEqualObjects(vc.navigationItem.title, displayOpts.navigationBarTitleCopy);
    XCTAssertEqualObjects(vc.navigationController.navigationBar.barTintColor,
                          displayOpts.navigationBarBackgroundColor);
    NSDictionary *expectedTitleTextAttrs = @{
        NSForegroundColorAttributeName: displayOpts.navigationBarTitleTextColor,
        NSFontAttributeName: displayOpts.navigationBarTitleFont,
        };
    XCTAssertEqualObjects(vc.navigationController.navigationBar.titleTextAttributes, expectedTitleTextAttrs);
}

@end
