//
//  MAVECustomSharePageViewControllerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVEInvitePageChooser.h"

@interface MAVECustomSharePageViewControllerTests : XCTestCase

@end

@implementation MAVECustomSharePageViewControllerTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testViewDidLoadSetsUpNavigationBar {
    MAVECustomSharePageViewController *vc =
        [[MAVECustomSharePageViewController alloc] init];

    id chooserMock = OCMPartialMock([MaveSDK sharedInstance].invitePageChooser);

    OCMExpect([chooserMock setupNavigationBar:vc
                          leftBarButtonTarget:vc
                          leftBarButtonAction:@selector(dismissAfterCancel)]);

    [vc viewDidLoad];

    OCMVerifyAll(chooserMock);
}

- (void)testViewDidLoadLogsInvitePageView {
    MAVECustomSharePageViewController *vc =
        [[MAVECustomSharePageViewController alloc] init];

    id apiMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiMock trackInvitePageOpenForPageType:MAVEInvitePageTypeCustomShare]);

    [vc viewDidLoad];

    OCMVerifyAll(apiMock);
}

- (void)testDismissAfterCancel {
    MAVECustomSharePageViewController *vc =
        [[MAVECustomSharePageViewController alloc] init];
    [vc loadView];
    __block BOOL numInvites;
    __block BOOL called;
    [MaveSDK sharedInstance].invitePageDismissalBlock =
        ^(UIViewController *vc, NSUInteger numberOfInvitesSent) {
            called = YES;
            numInvites = numberOfInvitesSent;
        };
    id viewMock = OCMPartialMock(vc.view);
    OCMExpect([viewMock endEditing:YES]);

    [vc dismissAfterCancel];

    OCMVerifyAll(viewMock);
    XCTAssertTrue(called);
    XCTAssertEqual(numInvites, 0);
}

@end
