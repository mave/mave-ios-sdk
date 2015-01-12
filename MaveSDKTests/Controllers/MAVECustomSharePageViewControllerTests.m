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
#import "MAVEShareToken.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVEInvitePageChooser.h"

@interface MAVECustomSharePageViewControllerTests : XCTestCase

@property (nonatomic, strong) MAVECustomSharePageViewController *viewController;
@property (nonatomic, strong) id viewControllerMock;
@property (nonatomic, strong) MAVERemoteConfiguration *remoteConfig;
@property (nonatomic, copy) NSString *shareToken;

@end

@implementation MAVECustomSharePageViewControllerTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    self.viewController = nil;
    self.viewControllerMock = nil;
    self.remoteConfig = nil;
    self.shareToken = nil;
}

- (void)tearDown {
    if (self.viewControllerMock) {
        [self.viewControllerMock stopMocking];
    }
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
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    OCMExpect([vc dismissSelf:0]);
    [vc dismissAfterCancel];
    OCMVerifyAll(mock);
}

# pragma mark - Share methods
// setup helper for some methods that want mocked data
- (void)setupPartialMockForClientShareTests {
    self.viewController = [[MAVECustomSharePageViewController alloc] init];
    self.remoteConfig = [[MAVERemoteConfiguration alloc] initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    self.shareToken = @"foobarsharetoken";

    self.viewControllerMock = OCMPartialMock(self.viewController);
    OCMStub([self.viewControllerMock remoteConfiguration]).andReturn(self.remoteConfig);
    OCMStub([self.viewControllerMock shareToken]).andReturn(self.shareToken);
}
- (void)testSetupMock {
    [self setupPartialMockForClientShareTests];
}

- (void)testClientSideSMSShare {
    [self setupPartialMockForClientShareTests];
    NSString *expectedSMS = @"Join me on DemoApp! http://dev.appjoin.us/s/foobarsharetoken";

    // SMS compose controller can't even init in the simulator, i.e:
    MFMessageComposeViewController *_cntrlr = [[MFMessageComposeViewController alloc] init];
    XCTAssertNil(_cntrlr);

    // So we mock it
    id smsComposerMock = OCMClassMock([MFMessageComposeViewController class]);
    OCMExpect([self.viewControllerMock _createMessageComposeViewController]).andReturn(smsComposerMock);

    OCMExpect([self.viewControllerMock presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
        MFMessageComposeViewController *controller = (MFMessageComposeViewController *)obj;
        XCTAssertNotNil(controller);
        XCTAssertEqualObjects(controller, smsComposerMock);
        return YES;
    }] animated:YES completion:nil]);

    OCMExpect([smsComposerMock setMessageComposeDelegate:self.viewController]);
    OCMExpect([smsComposerMock setBody:expectedSMS]);

    [self.viewController smsClientSideShare];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(smsComposerMock);
}

- (void)testClientSideSMSShareHandler {

}

- (void)testClientEmailShare {
    [self setupPartialMockForClientShareTests];

    OCMExpect([self.viewControllerMock presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
        MFMailComposeViewController *controller = obj;
        XCTAssertNotNil(controller);
        return YES;
    }] animated:YES completion:nil]);

    [self.viewController emailClientSideShare];

    OCMVerifyAll(self.viewControllerMock);
}


#pragma mark - Helpers for building share content
- (void)testShareToken {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    MAVEShareToken *tokenObj = [[MAVEShareToken alloc] init];
    tokenObj.shareToken = @"blahasdf";

    id mock = OCMPartialMock([MaveSDK sharedInstance].shareTokenBuilder);
    OCMExpect([mock createObjectSynchronousWithTimeout:0]).andReturn(tokenObj);
    NSString *token = [vc shareToken];
    OCMVerifyAll(mock);
    XCTAssertEqualObjects(token, @"blahasdf");
}
- (void)testBuildShareLink {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    OCMStub([mock shareToken]).andReturn(@"blahtok");
    NSString *link = [vc shareLinkWithSubRouteLetter:@"d"];
    XCTAssertEqualObjects(link, @"http://dev.appjoin.us/d/blahtok");
}

@end
