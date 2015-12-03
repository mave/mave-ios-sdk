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

- (void)testGenericButtonStyles {
    UIColor *iconColor = [UIColor redColor];
    UIColor *backgroundColor = [UIColor blackColor];
    UIFont *iconFont = [UIFont systemFontOfSize:11.25];

    id uiUtilsMock = OCMClassMock([MAVEBuiltinUIElementUtils class]);
    OCMExpect([uiUtilsMock tintWhitesInImage:[OCMArg any] withColor:iconColor]);


    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    view.iconColor = iconColor;
    view.iconTextColor = iconColor;
    view.iconFont = iconFont;
    view.backgroundColor = backgroundColor;
    view.useSmallIcons = NO;
    view.allowSMSShare = YES;
    UIButton *button = [view genericShareButtonWithIconNamed:@"MAVEShareIconSMS.png" andLabelText:@"FooBar"];

    OCMVerifyAll(uiUtilsMock);
    XCTAssertFalse(view.useSmallIcons);
    XCTAssertEqualObjects(button.currentTitle, @"FooBar");
    XCTAssertEqualObjects(button.currentTitleColor, iconColor);
    XCTAssertEqualObjects(button.titleLabel.font,
                          iconFont);
    XCTAssertEqualObjects(view.backgroundColor, backgroundColor);
}

- (void)testInitSetsUpShareToken {
    id sharerMock = OCMClassMock([MAVESharer class]);
    id obj = [[MAVEShareButtonsView alloc] init];

    OCMVerify([sharerMock setupShareToken]);
    XCTAssertNotNil(obj);
}

- (void)testInitSetsAllowAllShareOptionsToTrue {
    MAVEShareButtonsView *obj = [[MAVEShareButtonsView alloc] init];

    XCTAssertTrue(obj.allowSMSShare);
    XCTAssertTrue(obj.allowEmailShare);
    XCTAssertTrue(obj.allowNativeFacebookShare);
    XCTAssertTrue(obj.allowNativeTwitterShare);
    XCTAssertTrue(obj.allowClipboardShare);
}

- (void)testSetupShareButtonsWhenAllAllowedTrue {
    MAVEShareButtonsView *obj = [[MAVEShareButtonsView alloc] init];
    [obj shareButtonSize]; // triggers laying out share buttons
    // on simulator, only email & clipboard actually work
    XCTAssertEqual([obj.shareButtons count], 2);
}

- (void)testSettingAllowOptionsToNoDoesntIncludeThem {
    MAVEShareButtonsView *obj = [[MAVEShareButtonsView alloc] init];
    obj.allowSMSShare = NO; obj.allowEmailShare = NO;
    obj.allowNativeFacebookShare = NO; obj.allowNativeTwitterShare = NO;
    obj.allowClipboardShare = NO;
    [obj shareButtonSize]; // triggers laying out share buttons

    XCTAssertEqual([obj.shareButtons count], 0);
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
    [MaveSDK setupSharedInstance];
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
    OCMExpect([sharerMock composeClientEmailInviteToRecipientEmails:nil withCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMailComposeViewController *controller, MFMailComposeResult result) = obj;
        completionBlock(nil, MFMailComposeResultSent);
        return YES;
    }]]);
    OCMExpect([mock afterShareActions]);

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doClientEmailShare];

    OCMVerifyAll(mock);
    OCMVerifyAll(vcMock);
    OCMVerifyAll(sharerMock);
}

- (void)testDoEmailShareCanceled {
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];
    id mock = OCMPartialMock(view);
    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composeClientEmailInviteToRecipientEmails:nil withCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MFMailComposeViewController *controller, MFMailComposeResult result) = obj;
        completionBlock(nil, MFMailComposeResultCancelled);
        return YES;
    }]]);
    [[mock reject] afterShareActions];

    id vcMock = OCMClassMock([UIViewController class]);
    OCMExpect([mock presentingViewController]).andReturn(vcMock);
    OCMExpect([vcMock presentViewController:[OCMArg any] animated:YES completion:nil]);

    [view doClientEmailShare];

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
    MAVEShareButtonsView *view = [[MAVEShareButtonsView alloc] init];

    id sharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([sharerMock composePasteboardShare]);

    [view doClipboardShare];
    
    OCMVerifyAll(sharerMock);
}


@end
