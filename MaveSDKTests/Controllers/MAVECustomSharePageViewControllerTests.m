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
#import "MAVEConstants.h"
#import "MAVEShareToken.h"
#import "MAVECustomSharePageViewController.h"
#import "MAVEInvitePageChooser.h"
#import "MAVEClientPropertyUtils.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVECustomSharePageViewControllerTests : XCTestCase

@property (nonatomic, strong) MAVECustomSharePageViewController *viewController;
@property (nonatomic, strong) id viewControllerMock;
@property (nonatomic, strong) id sharerMock;
@property (nonatomic, strong) MAVERemoteConfiguration *remoteConfig;
@property (nonatomic, copy) NSString *applicationID;
@property (nonatomic, copy) NSString *shareToken;

@end

@implementation MAVECustomSharePageViewControllerTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
    self.applicationID = @"foo123";
    [MaveSDK setupSharedInstanceWithApplicationID:self.applicationID];
    self.viewController = nil;
    self.viewControllerMock = nil;
    self.sharerMock = nil;
    self.remoteConfig = nil;
    self.shareToken = nil;
}

- (void)tearDown {
    if (self.viewControllerMock) {
        [self.viewControllerMock stopMocking];
    }
    [super tearDown];
}

- (void)testViewDidLoadLogsInvitePageView {
    MAVECustomSharePageViewController *vc =
        [[MAVECustomSharePageViewController alloc] init];

    id apiMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiMock trackInvitePageOpenForPageType:MAVEInvitePageTypeCustomShare]);

    [vc viewDidLoad];

    OCMVerifyAll(apiMock);
}

- (void)testDismissAfterShare {
    [MaveSDK sharedInstance].invitePageChooser = [[MAVEInvitePageChooser alloc] init];
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    [MaveSDK sharedInstance].invitePageChooser.activeViewController = vc;

    id mock = OCMPartialMock([MaveSDK sharedInstance].invitePageChooser);
    OCMExpect([mock dismissOnSuccess:1]);
    [vc dismissAfterShare];
    OCMVerifyAll(mock);
}

# pragma mark - Share methods
// setup helper for some methods that want mocked data
- (void)setupPartialMockForClientShareTests {
    self.viewController = [[MAVECustomSharePageViewController alloc] init];
    self.viewController.sharerObject = [[MAVESharer alloc] init];
    self.remoteConfig = [[MAVERemoteConfiguration alloc] initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    self.shareToken = @"foobarsharetoken";

    self.sharerMock = OCMPartialMock(self.viewController.sharerObject);
    self.viewControllerMock = OCMPartialMock(self.viewController);
    OCMStub([self.sharerMock remoteConfiguration]).andReturn(self.remoteConfig);
    OCMStub([self.sharerMock shareToken]).andReturn(self.shareToken);
}
- (void)testSetupMock {
    [self setupPartialMockForClientShareTests];
}

- (void)testClientSideSMSShareSent {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeClientSMSInviteToRecipientPhones:nil completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMessageComposeViewController *controller, MessageComposeResult result) = obj;
        completionBlock(nil, MessageComposeResultSent);
        return YES;
    }]]);
    OCMExpect([mock presentViewController:[OCMArg any] animated:YES completion:nil]);
    OCMExpect([mock dismissAfterShare]);

    [vc smsClientSideShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testClientSideSMSShareCanceled {
    // On cancel, we don't dismiss the share page view controller
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeClientSMSInviteToRecipientPhones:nil completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMessageComposeViewController *controller, MessageComposeResult result) = obj;
        completionBlock(nil, MessageComposeResultCancelled);
        return YES;
    }]]);
    OCMExpect([mock presentViewController:[OCMArg any] animated:YES completion:nil]);
    [[mock reject] dismissAfterShare];

    [vc smsClientSideShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testClientSideSMSShareFailed {
    // Failed is same as cancel, the underlying helper displays the error alert
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeClientSMSInviteToRecipientPhones:nil completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMessageComposeViewController *controller, MessageComposeResult result) = obj;
        completionBlock(nil, MessageComposeResultFailed);
        return YES;
    }]]);
    OCMExpect([mock presentViewController:[OCMArg any] animated:YES completion:nil]);
    [[mock reject] dismissAfterShare];

    [vc smsClientSideShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

#pragma mark - client Email

- (void)testClientSideEmailShareSent {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeClientEmailWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMailComposeViewController *controller, MFMailComposeResult result) = obj;
        completionBlock(nil, MFMailComposeResultSent);
        return YES;
    }]]);
    OCMExpect([mock presentViewController:[OCMArg any] animated:YES completion:nil]);
    OCMExpect([mock dismissAfterShare]);

    [vc emailClientSideShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testFacebookiOSNativeShare {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeFacebookNativeShareWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = obj;
        completionBlock(nil, SLComposeViewControllerResultDone);
        return YES;
    }]]);
    OCMExpect([mock presentViewController:[OCMArg any] animated:YES completion:nil]);
    OCMExpect([mock dismissAfterShare]);

    [vc facebookiOSNativeShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testFacebookiOSNativeShareCanceled {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeFacebookNativeShareWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = obj;
        completionBlock(nil, SLComposeViewControllerResultCancelled);
        return YES;
    }]]);
    OCMExpect([mock presentViewController:[OCMArg any] animated:YES completion:nil]);
    [[mock reject] dismissAfterShare];

    [vc facebookiOSNativeShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testTwitteriOSNativeShare {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeTwitterNativeShareWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = obj;
        completionBlock(nil, SLComposeViewControllerResultDone);
        return YES;
    }]]);
    OCMExpect([mock presentViewController:[OCMArg any] animated:YES completion:nil]);
    OCMExpect([mock dismissAfterShare]);

    [vc twitteriOSNativeShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testTwitteriOSNativeShareCanceled {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];
    id mock = OCMPartialMock(vc);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeTwitterNativeShareWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = obj;
        completionBlock(nil, SLComposeViewControllerResultCancelled);
        return YES;
    }]]);
    OCMExpect([mock presentViewController:[OCMArg any] animated:YES completion:nil]);
    [[mock reject] dismissAfterShare];

    [vc twitteriOSNativeShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void) testClipboardShare {
    MAVECustomSharePageViewController *vc = [[MAVECustomSharePageViewController alloc] init];

    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composePasteboardShare]);

    [vc clipboardShare];

    OCMVerifyAll(sharerMock);
}

@end
