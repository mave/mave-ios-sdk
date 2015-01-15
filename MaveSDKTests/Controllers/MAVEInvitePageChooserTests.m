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
#import "MAVERemoteConfiguration.h"
#import "MAVERemoteConfigurationContactsInvitePage.h"
#import "MAVEInvitePageViewController.h"
#import "MAVECustomSharePageViewController.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEInvitePageChooserTests : XCTestCase

@end

@implementation MAVEInvitePageChooserTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitForModalPresent {
    MAVEInvitePageDismissBlock dismissBlock = ^(UIViewController *controller, NSUInteger numberOfInvitesSent) {};
    MAVEInvitePageChooser *ipc = [[MAVEInvitePageChooser alloc] initForModalPresentWithCancelBlock:dismissBlock];

    XCTAssertEqualObjects(ipc.navigationPresentedFormat, MAVEInvitePagePresentFormatModal);
    XCTAssertEqualObjects(ipc.navigationCancelBlock, dismissBlock);
    XCTAssertNil(ipc.navigationBackBlock);
    XCTAssertNil(ipc.navigationForwardBlock);
}

- (void)testInitForPushPresent {
    MAVEInvitePageDismissBlock backBlock = ^(UIViewController *controller, NSUInteger numberOfInvitesSent) {};
    MAVEInvitePageDismissBlock nextBlock = ^(UIViewController *controller, NSUInteger numberOfInvitesSent) {};
    MAVEInvitePageChooser *ipc = [[MAVEInvitePageChooser alloc] initForPushPresentWithBackBlock:backBlock nextBlock:nextBlock];

    XCTAssertEqualObjects(ipc.navigationPresentedFormat, MAVEInvitePagePresentFormatPush);
    XCTAssertEqualObjects(ipc.navigationBackBlock, backBlock);
    XCTAssertEqualObjects(ipc.navigationForwardBlock, nextBlock);
    XCTAssertNil(ipc.navigationCancelBlock);
}

- (void)testChooseAndCreateInvitePageViewControllerAddressBookDenied {

}

- (void)testChooseAndCreateFallsBackToShareSheetIfNoUserData {
    [MaveSDK sharedInstance].userData = nil;
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    UIViewController *vc = [chooser chooseAndCreateInvitePageViewController];
    XCTAssertEqualObjects(NSStringFromClass([vc class]), @"MAVECustomSharePageViewController");
}


# pragma mark - Tests for logic that determines which page to show

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

- (void)testIsContactsInvitePageEnabledServerSide {
    // Setup objects
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
    remoteConfig.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] init];

    // Setup mock, test when enabled NO
    id configBuilderMock = OCMPartialMock([MaveSDK sharedInstance].remoteConfigurationBuilder);
    OCMExpect([configBuilderMock createObjectSynchronousWithTimeout:0]).andReturn(remoteConfig);
    remoteConfig.contactsInvitePage.enabled = NO;
    XCTAssertFalse([chooser isContactsInvitePageEnabledServerSide]);

    OCMVerifyAll(configBuilderMock);
    [configBuilderMock stopMocking];

    // Reset mock, test when enabled YES
    configBuilderMock = OCMPartialMock([MaveSDK sharedInstance].remoteConfigurationBuilder);
    remoteConfig.contactsInvitePage.enabled = YES;
    OCMExpect([configBuilderMock createObjectSynchronousWithTimeout:0]).andReturn(remoteConfig);
    XCTAssertTrue([chooser isContactsInvitePageEnabledServerSide]);

    OCMVerifyAll(configBuilderMock);
}


#pragma mark - Create invite page methods

- (void)testCreateAddressBookInvitePage {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    UIViewController *vc = [chooser createAddressBookInvitePage];
    XCTAssertNotNil(vc);
    XCTAssertEqualObjects(NSStringFromClass([MAVEInvitePageViewController class]),
                          @"MAVEInvitePageViewController");
    XCTAssertEqualObjects(chooser.activeViewController, vc);
}

- (void)testCreateCustomShareInvitePage {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    UIViewController *vc = [chooser createCustomShareInvitePage];
    XCTAssertNotNil(vc);
    XCTAssertEqualObjects(NSStringFromClass([MAVECustomSharePageViewController class]),
                          @"MAVECustomSharePageViewController");
    XCTAssertEqualObjects(chooser.activeViewController, vc);
}

#pragma mark - Navigation controller setup logic

- (void)testSetupNavigationBarForActiveViewControllerModal {
    // If presented modal, should do modal button setup
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    chooser.navigationPresentedFormat = MAVEInvitePagePresentFormatModal;
    UIViewController *vc = [[UIViewController alloc] init];
    chooser.activeViewController = vc;
    XCTAssertNil(chooser.activeViewController.navigationController);

    id chooserMock = OCMPartialMock(chooser);
    OCMExpect([chooserMock _embedActiveViewControllerInNewNavigationController]);
    OCMExpect([chooserMock _styleNavigationItemForActiveViewController]);
    OCMExpect([chooserMock _setupNavigationBarButtonsModalStyle]);

    [chooser setupNavigationBarForActiveViewController];

    OCMVerifyAll(chooserMock);
}

- (void)testSetupNavigationBarForActiveViewControllerPush {
    // If presented push, should do push button setup
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    chooser.navigationPresentedFormat = MAVEInvitePagePresentFormatPush;
    UIViewController *vc = [[UIViewController alloc] init];
    chooser.activeViewController = vc;

    id chooserMock = OCMPartialMock(chooser);
    OCMExpect([chooserMock _embedActiveViewControllerInNewNavigationController]);
    OCMExpect([chooserMock _styleNavigationItemForActiveViewController]);
    OCMExpect([chooserMock _setupNavigationBarButtonsPushStyle]);

    [chooser setupNavigationBarForActiveViewController];

    OCMVerifyAll(chooserMock);
}

- (void)testEmbedInNavigationController {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    chooser.activeViewController = [[UIViewController alloc] init];
    XCTAssertNil(chooser.activeViewController.navigationController);

    [chooser _embedActiveViewControllerInNewNavigationController];

    XCTAssertNotNil(chooser.activeViewController.navigationController);
}

- (void)testStyleNavigationController {
    // Uses display options from the singleton
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];
    MAVEDisplayOptions *displayOpts = [MAVEDisplayOptionsFactory generateDisplayOptions];
    [MaveSDK sharedInstance].displayOptions = displayOpts;

    // set up view controller & chooser
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    UIViewController *vc = [[UIViewController alloc] init];
    chooser.activeViewController = vc;
    [chooser _embedActiveViewControllerInNewNavigationController];

    [chooser _styleNavigationItemForActiveViewController];

    XCTAssertEqualObjects(vc.navigationItem.title, displayOpts.navigationBarTitleCopy);
    XCTAssertEqualObjects(vc.navigationController.navigationBar.barTintColor,
                          displayOpts.navigationBarBackgroundColor);
    NSDictionary *expectedTitleTextAttrs = @{
                                             NSForegroundColorAttributeName: displayOpts.navigationBarTitleTextColor,
                                             NSFontAttributeName: displayOpts.navigationBarTitleFont,
                                             };
    XCTAssertEqualObjects(vc.navigationController.navigationBar.titleTextAttributes,
                          expectedTitleTextAttrs);
}

- (void)testSetupNavigationButtonsModalWhenCustom {
    [MaveSDK sharedInstance].displayOptions.navigationBarCancelButton = [[UIBarButtonItem alloc] init];
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    chooser.activeViewController = [[UIViewController alloc] init];

    [chooser _setupNavigationBarButtonsModalStyle];

    UIBarButtonItem *cancelButton = chooser.activeViewController.navigationItem.leftBarButtonItem;
    XCTAssertEqualObjects(cancelButton,
                          [MaveSDK sharedInstance].displayOptions.navigationBarCancelButton);
    XCTAssertEqualObjects(cancelButton.target, chooser);
    XCTAssertEqual(cancelButton.action, @selector(handleCancelAction));
}

- (void)testSetupNavigationButtonsModalDefaults {
    [MaveSDK sharedInstance].displayOptions.navigationBarCancelButton = nil;
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    chooser.activeViewController = [[UIViewController alloc] init];

    [chooser _setupNavigationBarButtonsModalStyle];

    UIBarButtonItem *cancelButton = chooser.activeViewController.navigationItem.leftBarButtonItem;
    XCTAssertEqualObjects(cancelButton.title, @"Cancel");
    XCTAssertEqual(cancelButton.style, UIBarButtonItemStylePlain);
    XCTAssertEqualObjects(cancelButton.target, chooser);
    XCTAssertEqual(cancelButton.action, @selector(handleCancelAction));
}

- (void)testSetupNavigationButtonsPushWhenCustom {
    [MaveSDK sharedInstance].displayOptions.navigationBarBackButton = [[UIBarButtonItem alloc] init];
    [MaveSDK sharedInstance].displayOptions.navigationBarForwardButton = [[UIBarButtonItem alloc] init];
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    chooser.activeViewController = [[UIViewController alloc] init];

    [chooser _setupNavigationBarButtonsPushStyle];

    UIBarButtonItem *backButton = chooser.activeViewController.navigationItem.leftBarButtonItem;
    UIBarButtonItem *forwardButton = chooser.activeViewController.navigationItem.rightBarButtonItem;
    XCTAssertEqualObjects(backButton,
                          [MaveSDK sharedInstance].displayOptions.navigationBarBackButton);
    XCTAssertEqualObjects(backButton.target, chooser);
    XCTAssertEqual(backButton.action, @selector(handleBackAction));

    XCTAssertEqualObjects(forwardButton, [MaveSDK sharedInstance].displayOptions.navigationBarForwardButton);
    XCTAssertEqualObjects(forwardButton.target, chooser);
    XCTAssertEqual(forwardButton.action, @selector(handleForwardAction));
}

- (void)testsetupnavigationButtonsPushDefaults {
    [MaveSDK sharedInstance].displayOptions.navigationBarBackButton = nil;
    [MaveSDK sharedInstance].displayOptions.navigationBarForwardButton = nil;
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];
    chooser.activeViewController = [[UIViewController alloc] init];

    [chooser _setupNavigationBarButtonsPushStyle];

    UIBarButtonItem *backButton = chooser.activeViewController.navigationItem.leftBarButtonItem;
    UIBarButtonItem *forwardButton = chooser.activeViewController.navigationItem.rightBarButtonItem;

    // Back button not build yet
    XCTAssertNil(backButton);
    XCTAssertNotNil(forwardButton);
    XCTAssertEqualObjects(forwardButton.title, @"Skip");
    XCTAssertEqual(forwardButton.style, UIBarButtonItemStylePlain);
    XCTAssertEqualObjects(forwardButton.target, chooser);
    XCTAssertEqual(forwardButton.action, @selector(handleForwardAction));
}

///
/// Forward and back/cancel actions
///



// Navigation bar
- (void)testEmbedInNavigationControllerOld {
    MAVEInvitePageChooser *chooser = [[MAVEInvitePageChooser alloc] init];

    UIViewController *viewController = [[UIViewController alloc] init];
    UINavigationController *sampleNavigationController =
        [chooser embedInNavigationController:viewController];

    XCTAssertNotNil(sampleNavigationController);
    XCTAssertEqualObjects(sampleNavigationController, viewController.navigationController);
}



// Tests for old style method
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
