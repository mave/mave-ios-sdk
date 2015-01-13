//
//  MAVECustomSharePageViewControllerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVEShareToken.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVEInvitePageChooser.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

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
    OCMExpect([mock dismissSelf:0]);
    [vc dismissAfterCancel];
    OCMVerifyAll(mock);
}

- (void)testDismissAfterShare {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    OCMExpect([mock dismissSelf:1]);
    OCMExpect([mock resetShareToken]);
    [vc dismissAfterShare];
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

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:@"client_sms"]);

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
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testClientSideSMSShareHandlerSMSSent {
    [self setupPartialMockForClientShareTests];

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([self.viewControllerMock dismissAfterShare]);
    OCMExpect([self.viewControllerMock dismissViewControllerAnimated:YES completion:nil]);
    OCMExpect([apiInterfaceMock trackShareWithShareType:@"client_sms" shareToken:[self.viewController shareToken] audience:nil]);

    [self.viewController messageComposeViewController:nil didFinishWithResult:MessageComposeResultSent];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testClientSideSMSShareHandlerSMSCancelled {
    [self setupPartialMockForClientShareTests];

    // When cancelled
    [[[self.viewControllerMock reject] ignoringNonObjectArgs] dismissAfterShare];
    OCMExpect([self.viewControllerMock dismissViewControllerAnimated:YES completion:nil]);

    [self.viewController messageComposeViewController:nil didFinishWithResult:MessageComposeResultCancelled];

    OCMVerifyAll(self.viewControllerMock);
}

- (void)testClientSideSMSShareHandlerSMSFailed {
    [self setupPartialMockForClientShareTests];

    // When failed
    [[[self.viewControllerMock reject] ignoringNonObjectArgs] dismissAfterShare];
    OCMExpect([self.viewControllerMock dismissViewControllerAnimated:YES completion:nil]);

    // TODO figure out how to mock the UIAlertView

    [self.viewController messageComposeViewController:nil didFinishWithResult:MessageComposeResultCancelled];

    OCMVerifyAll(self.viewControllerMock);
}

- (void)testClientEmailShare {
    [self setupPartialMockForClientShareTests];
    NSString *expectedSubject = @"Join DemoApp";
    NSString *expectedBody = @"Hey, I've been using DemoApp and thought you might like it. Check it out:\n\nhttp://dev.appjoin.us/e/foobarsharetoken";

    id mailComposerMock = OCMClassMock([MFMailComposeViewController class]);
    OCMExpect([self.viewControllerMock _createMailComposeViewController]).andReturn(mailComposerMock);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:@"client_email"]);

    OCMExpect([self.viewControllerMock presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
        MFMailComposeViewController *controller = obj;
        XCTAssertEqualObjects(controller, mailComposerMock);
        return YES;
    }] animated:YES completion:nil]);

    OCMExpect([mailComposerMock setMailComposeDelegate:self.viewController]);
    OCMExpect([mailComposerMock setSubject:expectedSubject]);
    OCMExpect([mailComposerMock setMessageBody:expectedBody isHTML:NO]);

    [self.viewController emailClientSideShare];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(mailComposerMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testClientEmailHandlerEmailSent {
    [self setupPartialMockForClientShareTests];

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([self.viewControllerMock dismissAfterShare]);
    OCMExpect([self.viewControllerMock dismissViewControllerAnimated:YES completion:nil]);
    OCMExpect([apiInterfaceMock trackShareWithShareType:@"client_email" shareToken:[self.viewController shareToken] audience:nil]);

    [self.viewController mailComposeController:nil didFinishWithResult:MFMailComposeResultSent error:nil];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testClientEmailHandlerEmailNotSent {
    [self setupPartialMockForClientShareTests];

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[self.viewControllerMock reject] dismissAfterShare];
    OCMExpect([self.viewControllerMock dismissViewControllerAnimated:YES completion:nil]);
    [[apiInterfaceMock reject] trackShareWithShareType:@"client_email" shareToken:[self.viewController shareToken] audience:nil];

    [self.viewController mailComposeController:nil didFinishWithResult:MFMailComposeResultCancelled error:nil];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testFacebookiOSNativeShare {
    [self setupPartialMockForClientShareTests];
    NSString *expectedCopy = @"I love DemoApp. You should try it.";
    NSString *expectedURL = @"http://dev.appjoin.us/f/foobarsharetoken";

    id fbVC = OCMClassMock([SLComposeViewController class]);
    OCMExpect([self.viewControllerMock _createFacebookComposeViewController]).andReturn(fbVC);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:@"facebook"]);

    OCMExpect([self.viewControllerMock presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
        SLComposeViewController *controller = obj;
        XCTAssertEqualObjects(controller, fbVC);
        return YES;
    }] animated:YES completion:nil]);

    OCMExpect([fbVC setCompletionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(SLComposeViewControllerResult result) = obj;
        completionBlock(SLComposeViewControllerResultDone);
        return YES;
    }]]);
    OCMExpect([fbVC setInitialText:expectedCopy]);
    OCMExpect([fbVC addURL:[NSURL URLWithString:expectedURL]]);

    OCMExpect([self.viewControllerMock facebookHandleShareResult:SLComposeViewControllerResultDone]);

    [self.viewController facebookiOSNativeShare];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(fbVC);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testFacebookHandleShareResultDone {
    [self setupPartialMockForClientShareTests];

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareWithShareType:@"facebook" shareToken:[self.viewController shareToken] audience:nil]);
    OCMExpect([self.viewControllerMock dismissAfterShare]);
    OCMExpect([self.viewControllerMock dismissViewControllerAnimated:YES completion:nil]);
    [self.viewControllerMock facebookHandleShareResult:SLComposeViewControllerResultDone];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testFacebookHandleShareResultCancelled {
    [self setupPartialMockForClientShareTests];

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject] trackShareWithShareType:@"facebook" shareToken:[self.viewController shareToken] audience:nil];
    [[self.viewControllerMock reject] dismissAfterShare];
    OCMExpect([self.viewControllerMock dismissViewControllerAnimated:YES completion:nil]);
    [self.viewControllerMock facebookHandleShareResult:SLComposeViewControllerResultCancelled];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testTwitteriOSNativeShare {
    [self setupPartialMockForClientShareTests];
    NSString *expectedCopy = @"I love DemoApp. Try it out http://dev.appjoin.us/t/foobarsharetoken";

    id twitterVC = OCMClassMock([SLComposeViewController class]);
    OCMExpect([self.viewControllerMock _createTwitterComposeViewController]).andReturn(twitterVC);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:@"twitter"]);

    OCMExpect([self.viewControllerMock presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
        SLComposeViewController *controller = obj;
        XCTAssertEqualObjects(controller, twitterVC);
        return YES;
    }] animated:YES completion:nil]);

    OCMExpect([twitterVC setCompletionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(SLComposeViewControllerResult result) = obj;
        completionBlock(SLComposeViewControllerResultDone);
        return YES;
    }]]);
    OCMExpect([twitterVC setInitialText:expectedCopy]);

    OCMExpect([self.viewControllerMock twitterHandleShareResult:SLComposeViewControllerResultDone]);

    [self.viewController twitteriOSNativeShare];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(twitterVC);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testTwitterHandleShareResultDone {
    [self setupPartialMockForClientShareTests];

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareWithShareType:@"twitter" shareToken:[self.viewController shareToken] audience:nil]);
    OCMExpect([self.viewControllerMock dismissAfterShare]);
    OCMExpect([self.viewControllerMock dismissViewControllerAnimated:YES completion:nil]);

    [self.viewControllerMock twitterHandleShareResult:SLComposeViewControllerResultDone];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testTwitterHandleShareResultCancelled {
    [self setupPartialMockForClientShareTests];

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject] trackShareWithShareType:@"twitter" shareToken:[self.viewController shareToken] audience:nil];
    [[self.viewControllerMock reject] dismissAfterShare];
    OCMExpect([self.viewControllerMock dismissViewControllerAnimated:YES completion:nil]);

    [self.viewControllerMock twitterHandleShareResult:SLComposeViewControllerResultCancelled];

    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(apiInterfaceMock);
}

- (void)testClipboardShare {
    [self setupPartialMockForClientShareTests];
    NSString *expectedShareCopy = @"http://dev.appjoin.us/c/foobarsharetoken";

// TODO: test taht remote config copy appended to link
//    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] init];
//    remoteConfig.clipboardShare = [[MAVERemoteConfigurationClipboardShare alloc] init];
//    remoteConfig.clipboardShare.text = @"Blah copy";
//
//    OCMExpect([self.viewControllerMock remoteConfiguration]).andReturn(remoteConfig);

    id pasteboardMock = OCMClassMock([UIPasteboard class]);
    OCMExpect([self.viewControllerMock _generalPasteboardForClipboardShare]).andReturn(pasteboardMock);
    // since any copy operation might get shared, reset the share token on copy to clipboard
    OCMExpect([self.viewControllerMock resetShareToken]);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:@"clipboard"]);

    // TODO: test the uialert view

    OCMExpect([pasteboardMock setString:expectedShareCopy]);

    [self.viewController clipboardShare];

    OCMVerifyAll(pasteboardMock);
    OCMVerifyAll(self.viewControllerMock);
    OCMVerifyAll(apiInterfaceMock);
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

- (void)testBuildShareCopyWhenCopyIsNormal {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    OCMExpect([mock shareLinkWithSubRouteLetter:@"d"]).andReturn(@"fakelink");

    NSString *text = [vc shareCopyFromCopy:@"foo"
                 andLinkWithSubRouteLetter:@"d"];

    NSString *expectedText = @"foo fakelink";

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(text, expectedText);
}

- (void)testBuildShareCopyWhenCopyEndsInSpace {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    OCMStub([mock shareLinkWithSubRouteLetter:@"d"]).andReturn(@"fakelink");

    NSString *text = [vc shareCopyFromCopy:@"foo "
                 andLinkWithSubRouteLetter:@"d"];

    NSString *expectedText = @"foo fakelink";
    XCTAssertEqualObjects(text, expectedText);

    // newline should count as a space too
    text = [vc shareCopyFromCopy:@"foo\n"
            andLinkWithSubRouteLetter:@"d"];

    expectedText = @"foo\nfakelink";
    XCTAssertEqualObjects(text, expectedText);
}

- (void)testBuildShareCopyWhenCopyIsEmpty {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    OCMExpect([mock shareLinkWithSubRouteLetter:@"d"]).andReturn(@"fakelink");

    NSString *text = [vc shareCopyFromCopy:nil
                 andLinkWithSubRouteLetter:@"d"];

    NSString *expectedText = @"fakelink";

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(text, expectedText);
}

- (void)testResetShareToken {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    MAVERemoteObjectBuilder *builderInitial = [MaveSDK sharedInstance].shareTokenBuilder;

    id stClassMock = OCMClassMock([MAVEShareToken class]);

    [vc resetShareToken];

    OCMVerify([stClassMock clearUserDefaults]);
    XCTAssertNotEqualObjects([MaveSDK sharedInstance].shareTokenBuilder, builderInitial);
    [stClassMock stopMocking];
}

@end
