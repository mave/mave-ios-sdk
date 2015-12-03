//
//  MAVEWrapperNavigationControllerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/31/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MaveSDK.h"
#import "MAVEWrapperNavigationController.h"

@interface MAVEWrapperNavigationControllerTests : XCTestCase

@end

@implementation MAVEWrapperNavigationControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStatusBarStyle {
    [MaveSDK setupSharedInstance];
    MaveSDK *mave = [MaveSDK sharedInstance];
    mave.displayOptions.statusBarStyle = UIStatusBarStyleLightContent;
    MAVEWrapperNavigationController *vc = [[MAVEWrapperNavigationController alloc] init];

    XCTAssertEqual([vc preferredStatusBarStyle], UIStatusBarStyleLightContent);
}

@end
