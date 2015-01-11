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
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];

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

- (void)testDismissSelf {
    MAVECustomSharePageViewController *vc =
        [[MAVECustomSharePageViewController alloc] init];
    [vc loadView];
    __block NSUInteger numInvites;
    __block BOOL called;
    [MaveSDK sharedInstance].invitePageDismissalBlock =
        ^(UIViewController *vc, NSUInteger numberOfInvitesSent) {
            called = YES;
            numInvites = numberOfInvitesSent;
        };
    id viewMock = OCMPartialMock(vc.view);
    OCMExpect([viewMock endEditing:YES]);

    [vc dismissSelf:101];

    OCMVerifyAll(viewMock);
    XCTAssertTrue(called);
    XCTAssertEqual(numInvites, 101);
}

- (void)testDismissAfterCancel {
    MAVECustomSharePageViewController *vc =
    [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    OCMExpect([vc dismissSelf:0]);
    [vc dismissAfterCancel];
    OCMVerifyAll(mock);
}

# pragma mark - Share methods
- (void)testClientSideSMSShare {

}


#pragma mark - Helpers for building share content
- (void)testBuildShareLink {
    NSString *link = [MAVECustomSharePageViewController buildShareLinkWithSubRouteLetter:@"d" shareToken:@"blahtok"];
    XCTAssertEqualObjects(link, @"http://dev.appjoin.us/d/blahtok");
}

@end
