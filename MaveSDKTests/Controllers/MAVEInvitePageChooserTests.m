//
//  MAVEInvitePageChooserTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/8/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEDisplayOptionsFactory.h"
#import "MaveSDK.h"
#import "MAVEInvitePageChooser.h"
#import "MAVEInvitePageViewController.h"
#import "MAVECustomSharePageViewController.h"

@interface MAVEInvitePageChooserTests : XCTestCase

@end

@implementation MAVEInvitePageChooserTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Helper functions tests
- (void)testUSIsInSupportedRegionForServerSideSMSInvites {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    NSDictionary *fakeCurrentLocale = @{NSLocaleCountryCode: @"US"};

    id localeClassMock = OCMClassMock([NSLocale class]);
    OCMExpect([localeClassMock autoupdatingCurrentLocale])
        .andReturn(fakeCurrentLocale);

    XCTAssertTrue([chooser isInSupportedRegionForServerSideSMSInvites]);
    OCMVerifyAll(localeClassMock);
    [localeClassMock stopMocking];

}
- (void)testOtherCountriesNotInSupportedRegion {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    NSDictionary *fakeCurrentLocale = @{NSLocaleCountryCode: @"Fr"};

    id localeClassMock = OCMClassMock([NSLocale class]);
    OCMExpect([localeClassMock autoupdatingCurrentLocale])
    .andReturn(fakeCurrentLocale);

    XCTAssertFalse([chooser isInSupportedRegionForServerSideSMSInvites]);
    OCMVerifyAll(localeClassMock);
}

- (void)testCreateAddressBookInvitePage {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    UIViewController *vc = [chooser createAddressBookInvitePage];
    XCTAssertNotNil(vc);
    XCTAssertTrue([vc isKindOfClass:[MAVEInvitePageViewController class]]);
}

- (void)testCreateCustomShareInvitePage {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    UIViewController *vc = [chooser createCustomShareInvitePage];
    XCTAssertNotNil(vc);
    XCTAssertTrue([vc isKindOfClass:[MAVECustomSharePageViewController class]]);
}

// Navigation bar
- (void)testEmbedInNavigationController {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];

    UIViewController *viewController = [[UIViewController alloc] init];
    UINavigationController *sampleNavigationController =
        [chooser embedInNavigationController:viewController];

    XCTAssertNotNil(sampleNavigationController);
    XCTAssertEqualObjects(sampleNavigationController, viewController.navigationController);
}

- (void)testSetupNavigationBarOnViewController {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];

    // Uses display options from the singleton
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];
    MAVEDisplayOptions *displayOpts = [MAVEDisplayOptionsFactory generateDisplayOptions];
    [MaveSDK sharedInstance].displayOptions = displayOpts;


    UIViewController *vc = [[UIViewController alloc] init];
    UINavigationController *sampleNavigationController =
        [chooser embedInNavigationController:vc];
    XCTAssertNotNil(sampleNavigationController);
    NSObject *someObject = [[NSObject alloc] init];

    [chooser setupNavigationBar:vc
            leftBarButtonTarget:someObject
            leftBarButtonAction:@selector(testEmbedInNavigationController)];
    XCTAssertEqualObjects(vc.navigationItem.title, displayOpts.navigationBarTitleCopy);
    XCTAssertEqualObjects(vc.navigationController.navigationBar.barTintColor,
                          displayOpts.navigationBarBackgroundColor);
    NSDictionary *expectedTitleTextAttrs = @{
        NSForegroundColorAttributeName: displayOpts.navigationBarTitleTextColor,
        NSFontAttributeName: displayOpts.navigationBarTitleFont,
    };
    XCTAssertEqualObjects(vc.navigationController.navigationBar.titleTextAttributes,
                          expectedTitleTextAttrs);

    XCTAssertEqualObjects(vc.navigationItem.leftBarButtonItem.target, someObject);
    XCTAssertEqual(vc.navigationItem.leftBarButtonItem.action,
                   @selector(testEmbedInNavigationController));
}

- (void)testSetupNavigationBarIfNone {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    NSObject *someObject = [[NSObject alloc] init];

    UIViewController *vc = [[UIViewController alloc] init];
    XCTAssertNil(vc.navigationController);

    [chooser setupNavigationBar:vc
            leftBarButtonTarget:someObject
            leftBarButtonAction:@selector(testEmbedInNavigationController)];

    XCTAssertNil(vc.navigationController);
}

@end
