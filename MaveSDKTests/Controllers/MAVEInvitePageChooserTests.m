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
#import "MAVEShareActions.h"

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
    XCTAssertTrue([vc isKindOfClass:[MAVEShareActions class]]);
}

// Navigation bar
- (void)testEmbedInNavigationController {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];

    UIViewController *vc = [[UIViewController alloc] init];
    UINavigationController *nc = [chooser embedInNavigationController:vc];

    XCTAssertNotNil(nc);
    XCTAssertEqualObjects(vc.navigationController, nc);
}

- (void)testSetupNavigationBarOnViewController {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];

    // Uses display options from the singleton
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];
    MAVEDisplayOptions *displayOpts = [MAVEDisplayOptionsFactory generateDisplayOptions];
    [MaveSDK sharedInstance].displayOptions = displayOpts;

    UIViewController *viewController = [[UIViewController alloc] init];
    UINavigationController *sampleNavigationController =
        [chooser embedInNavigationController:viewController];
    XCTAssertNotNil(sampleNavigationController);

    [chooser setupNavigationBar:viewController];
    XCTAssertEqualObjects(viewController.navigationItem.title, displayOpts.navigationBarTitleCopy);
    XCTAssertEqualObjects(viewController.navigationController.navigationBar.barTintColor,
                          displayOpts.navigationBarBackgroundColor);
    NSDictionary *expectedTitleTextAttrs = @{
                                             NSForegroundColorAttributeName: displayOpts.navigationBarTitleTextColor,
                                             NSFontAttributeName: displayOpts.navigationBarTitleFont,
                                             };
    XCTAssertEqualObjects(viewController.navigationController.navigationBar.titleTextAttributes,
                          expectedTitleTextAttrs);
}

@end
