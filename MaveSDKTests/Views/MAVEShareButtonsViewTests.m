//
//  MAVEShareIconsViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/26/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEShareButtonsView.h"
#import "MaveSDK.h"
#import "MAVEBuiltinUIElementUtils.h"
#import "MAVECustomSharePageView.h"
#import "MAVECustomSharePageViewController.h"

@interface MAVEShareButtonsViewTests : XCTestCase

@end

@implementation MAVEShareButtonsViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFullInitMethod {
    MAVECustomSharePageViewController *delegate = [[MAVECustomSharePageViewController alloc] init];
    UIColor *iconColor = [UIColor redColor];
    UIColor *backgroundColor = [UIColor blackColor];
    UIFont *iconFont = [UIFont systemFontOfSize:11.35];


    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] initWithDelegate:delegate iconColor:iconColor iconFont:iconFont backgroundColor:backgroundColor useSmallIcons:YES allowSMSShare:YES];

    XCTAssertEqualObjects(view.delegate, delegate);
    XCTAssertEqualObjects(view.iconColor, iconColor);
    XCTAssertEqualObjects(view.iconTextColor, iconColor);
    XCTAssertEqualObjects(view.iconFont, iconFont);
    XCTAssertEqualObjects(view.backgroundColor, backgroundColor);
    XCTAssertTrue(view.useSmallIcons);
    XCTAssertTrue(view.allowSMSShare);
}

- (void)testGenericButtonStyles {
    UIColor *iconColor = [UIColor redColor];
    UIColor *backgroundColor = [UIColor blackColor];
    UIFont *iconFont = [UIFont systemFontOfSize:11.25];

    id uiUtilsMock = OCMClassMock([MAVEBuiltinUIElementUtils class]);
    OCMExpect([uiUtilsMock tintWhitesInImage:[OCMArg any] withColor:iconColor]);

    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] initWithDelegate:nil iconColor:iconColor iconFont:iconFont backgroundColor:backgroundColor useSmallIcons:NO allowSMSShare:YES];
    UIButton *button = [view genericShareButtonWithIconNamed:@"MAVEShareIconSMS.png" andLabelText:@"FooBar"];

    OCMVerifyAll(uiUtilsMock);
    XCTAssertFalse(view.useSmallIcons);
    XCTAssertEqualObjects(button.currentTitle, @"FooBar");
    XCTAssertEqualObjects(button.currentTitleColor, iconColor);
    XCTAssertEqualObjects(button.titleLabel.font,
                          iconFont);
    XCTAssertEqualObjects(view.backgroundColor, backgroundColor);
}

#pragma mark - Test Share Actions

- (void)testAfterShareActionsDismissAfterShare {
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    view.dismissMaveTopLevelOnSuccessfulShare = YES;

    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock resetShareToken]);
    id chooserMock = OCMClassMock([MAVEInvitePageChooser class]);
    [MaveSDK sharedInstance].invitePageChooser = chooserMock;
    OCMExpect([chooserMock dismissOnSuccess:1]);

    [view afterShareActions];

    OCMVerifyAll(sharerMock);
    OCMVerifyAll(chooserMock);
}

- (void)testAfterShareActionsNoDismissAfterShare {
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    view.dismissMaveTopLevelOnSuccessfulShare = YES;

    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock resetShareToken]);
    id chooserMock = OCMClassMock([MAVEInvitePageChooser class]);
    [MaveSDK sharedInstance].invitePageChooser = chooserMock;
    [[chooserMock reject] dismissOnSuccess:1];

    [view afterShareActions];

    OCMVerifyAll(sharerMock);
    OCMVerifyAll(chooserMock);
}

- (void)testClientSideSMSShareSent {
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    id mock = OCMPartialMock(view);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeClientSMSInviteToRecipientPhones:nil completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMessageComposeViewController *controller, MessageComposeResult result) = obj;
        completionBlock(nil, MessageComposeResultSent);
        return YES;
    }]]);
    OCMExpect([mock afterShareActions]);

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doClientSMSShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(vcMock);
    OCMVerifyAll(sharerMock);
}

- (void)testClientSideSMSShareCanceled {
    // On cancel, we don't dismiss the share page view controller
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    id mock = OCMPartialMock(view);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeClientSMSInviteToRecipientPhones:nil completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMessageComposeViewController *controller, MessageComposeResult result) = obj;
        completionBlock(nil, MessageComposeResultCancelled);
        return YES;
    }]]);
    [[mock reject] afterShareActions];

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doClientSMSShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testDoEmailShareSent {
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    id mock = OCMPartialMock(view);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeClientEmailWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMailComposeViewController *controller, MFMailComposeResult result) = obj;
        completionBlock(nil, MFMailComposeResultSent);
        return YES;
    }]]);
    OCMExpect([mock afterShareActions]);

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doEmailShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(vcMock);
    OCMVerifyAll(sharerMock);
}

- (void)testDoEmailShareCanceled {
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    id mock = OCMPartialMock(view);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeClientEmailWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMailComposeViewController *controller, MFMailComposeResult result) = obj;
        completionBlock(nil, MFMailComposeResultCancelled);
        return YES;
    }]]);
    [[mock reject] afterShareActions];

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doEmailShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(vcMock);
    OCMVerifyAll(sharerMock);
}

- (void)testFacebookiOSNativeShare {
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    id mock = OCMPartialMock(view);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeFacebookNativeShareWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = obj;
        completionBlock(nil, SLComposeViewControllerResultDone);
        return YES;
    }]]);
    OCMExpect([mock afterShareActions]);

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doFacebookNativeiOSShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testFacebookiOSNativeShareCanceled {
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    id mock = OCMPartialMock(view);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeFacebookNativeShareWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = obj;
        completionBlock(nil, SLComposeViewControllerResultCancelled);
        return YES;
    }]]);
    [[mock reject] afterShareActions];

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doFacebookNativeiOSShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testTwitteriOSNativeShare {
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    id mock = OCMPartialMock(view);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeTwitterNativeShareWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = obj;
        completionBlock(nil, SLComposeViewControllerResultDone);
        return YES;
    }]]);
    OCMExpect([mock afterShareActions]);

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doTwitterNativeiOSShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(sharerMock);
}

- (void)testTwitteriOSNativeShareCanceled {
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    id mock = OCMPartialMock(view);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeTwitterNativeShareWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = obj;
        completionBlock(nil, SLComposeViewControllerResultCancelled);
        return YES;
    }]]);
    [[mock reject] afterShareActions];

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doTwitterNativeiOSShare];

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
