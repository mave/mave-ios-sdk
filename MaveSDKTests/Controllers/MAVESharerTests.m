//
//  MAVESharerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/6/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVESharer.h"
#import "MAVEShareToken.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVESharerTests : XCTestCase

@end

@implementation MAVESharerTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitAndRetainReleaseSelfMethods {
    MAVESharer *obj = [[MAVESharer alloc] initAndRetainSelf];
    XCTAssertEqualObjects(obj.retainedSelf, obj);
    [obj releaseSelf];
    XCTAssertNil(obj.retainedSelf);
}

#pragma mark - client SMS

- (void)testComposeClientSMSInvite {
    NSArray *recipientPhones = @[@"+18085551234", @"86753"];

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:MAVESharePageShareTypeClientSMS]);

    // we need to use a mock of this, because the simulator can't send texts
    // so this class can't even be initialized
    id messageComposeVCMock = OCMClassMock([MFMessageComposeViewController class]);
    OCMExpect([messageComposeVCMock canSendText]).andReturn(YES);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    OCMExpect([builderMock MFMessageComposeViewController]).andReturn(messageComposeVCMock);
    MAVESharer *sharerInstance = [[MAVESharer alloc] init];
    OCMExpect([builderMock sharerInstanceRetained]).andReturn(sharerInstance);

    // sms message text
    NSString *expectedMessageText = sharerInstance.remoteConfiguration.clientSMS.text;
    XCTAssertGreaterThan([expectedMessageText length], 0);
    OCMExpect([messageComposeVCMock setBody:expectedMessageText]);

    // sms recipient
    OCMExpect([messageComposeVCMock setRecipients:recipientPhones]);

    void (^myCompletionBlock)(MFMessageComposeViewController *controller, MessageComposeResult result) = ^void(MFMessageComposeViewController *controller, MessageComposeResult result) {};
    UIViewController *vc = [MAVESharer composeClientSMSInviteToRecipientPhones:recipientPhones completionBlock:myCompletionBlock];

    XCTAssertNotNil(vc);
    XCTAssertEqualObjects(vc, messageComposeVCMock);
    XCTAssertEqualObjects(sharerInstance.completionBlockClientSMS,
                          myCompletionBlock);

    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(messageComposeVCMock);
    OCMVerifyAll(builderMock);
}

- (void)testComposeClientSMSInviteNotWrappedInviteLink {
    // If userData.wrapInviteLink is NO andthere is a specified inviteLinkDestinationURL, that
    // inviteLinkDestinationURL should be included in the SMS copy rather than a wrapped appjoin link.
    NSArray *recipientPhones = @[@"+18085551234", @"86753"];
    
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:MAVESharePageShareTypeClientSMS]);
    
    // we need to use a mock of this, because the simulator can't send texts
    // so this class can't even be initialized
    id messageComposeVCMock = OCMClassMock([MFMessageComposeViewController class]);
    OCMExpect([messageComposeVCMock canSendText]).andReturn(YES);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    OCMExpect([builderMock MFMessageComposeViewController]).andReturn(messageComposeVCMock);
    MAVESharer *sharerInstance = [[MAVESharer alloc] init];
    OCMExpect([builderMock sharerInstanceRetained]).andReturn(sharerInstance);
    
    MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:@"1"
                                                        firstName:@"Example"
                                                         lastName:@"Person"];
    [[MaveSDK sharedInstance] identifyUser:userData];
    [MaveSDK sharedInstance].userData.inviteLinkDestinationURL = @"http://example.com/unwrapped/link";
    [MaveSDK sharedInstance].userData.wrapInviteLink = NO;
    
    // sms message text
    OCMExpect([messageComposeVCMock setBody:sharerInstance.remoteConfiguration.clientSMS.text]);
    
    // sms recipient
    OCMExpect([messageComposeVCMock setRecipients:recipientPhones]);
    
    void (^myCompletionBlock)(MFMessageComposeViewController *controller, MessageComposeResult result) = ^void(MFMessageComposeViewController *controller, MessageComposeResult result) {};
    UIViewController *vc = [MAVESharer composeClientSMSInviteToRecipientPhones:recipientPhones completionBlock:myCompletionBlock];
    
    XCTAssertNotNil(vc);
    XCTAssertEqualObjects(vc, messageComposeVCMock);
    XCTAssertEqualObjects(sharerInstance.completionBlockClientSMS,
                          myCompletionBlock);
    
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(messageComposeVCMock);
    OCMVerifyAll(builderMock);
}

- (void)testComposeClientSMSInviteReturnsNilIfCantSendSMS {
    XCTAssertFalse([MFMessageComposeViewController canSendText]);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    [[builderMock reject] sharerInstanceRetained];

    __block MessageComposeResult returnedComposeResult;
    __block BOOL wasCalled = NO;
    UIViewController *vc = [MAVESharer composeClientSMSInviteToRecipientPhones:nil completionBlock:^(MFMessageComposeViewController *controller, MessageComposeResult composeResult) {
        returnedComposeResult = composeResult;
        wasCalled = YES;
    }];
    XCTAssertNil(vc);
    XCTAssertTrue(wasCalled);
    XCTAssertEqual(returnedComposeResult, MessageComposeResultFailed);
    OCMVerifyAll(builderMock);
}

- (void)testComposeClientSMSCompletionBlockSuccess {
    MAVESharer *sharer = [[MAVESharer alloc] initAndRetainSelf];
    __block MessageComposeResult returnedResult;
    sharer.completionBlockClientSMS = ^void(MFMessageComposeViewController *controller, MessageComposeResult result) {
        returnedResult = result;
    };
    NSString *fakeToken = @"foo12398akj";
    id sharerMock = OCMPartialMock(sharer);
    OCMStub([sharerMock shareToken]).andReturn(fakeToken);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareWithShareType:MAVESharePageShareTypeClientSMS shareToken:fakeToken audience:nil]);

    id messageComposeVCMock = OCMClassMock([MFMessageComposeViewController class]);
    // should not get dismissed, the caller is responsible for dismissing controller in the block
    [[messageComposeVCMock reject] dismissViewControllerAnimated:YES completion:nil];
    [sharer messageComposeViewController:messageComposeVCMock didFinishWithResult:MessageComposeResultSent];

    XCTAssertEqual(returnedResult, MessageComposeResultSent);
    XCTAssertNil(sharer.retainedSelf);
    XCTAssertNil(sharer.completionBlockClientSMS);
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(messageComposeVCMock);
}

- (void)testComposeClientSMSCancelled {
    MAVESharer *sharer = [[MAVESharer alloc] initAndRetainSelf];
    __block MessageComposeResult returnedResult;
    sharer.completionBlockClientSMS = ^void(MFMessageComposeViewController *controller, MessageComposeResult result) {
        returnedResult = result;
    };

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject] trackShareWithShareType:MAVESharePageShareTypeClientSMS shareToken:[OCMArg any] audience:[OCMArg any]];

    id messageComposeVCMock = OCMClassMock([MFMessageComposeViewController class]);
    [[messageComposeVCMock reject] dismissViewControllerAnimated:YES completion:nil];
    [sharer messageComposeViewController:messageComposeVCMock didFinishWithResult:MessageComposeResultCancelled];

    XCTAssertEqual(returnedResult, MessageComposeResultCancelled);
    XCTAssertNil(sharer.retainedSelf);
    XCTAssertNil(sharer.completionBlockClientSMS);
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(messageComposeVCMock);
}

#pragma mark - client Email

- (void)testComposeClientEmailInvite {
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:MAVESharePageShareTypeClientEmail]);

    // use a mock of the vc
    id emailComposeVCMock = OCMClassMock([MFMailComposeViewController class]);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    OCMExpect([builderMock MFMailComposeViewController]).andReturn(emailComposeVCMock);
    MAVESharer *sharerInstance = [[MAVESharer alloc] init];
    OCMExpect([builderMock sharerInstanceRetained]).andReturn(sharerInstance);

    OCMExpect([emailComposeVCMock setMailComposeDelegate:sharerInstance]);

    // email message subject and body
    NSArray *recipients = @[@"foo@example.com", @"bar@example.com"];
    NSString *expectedMessageSubject = sharerInstance.remoteConfiguration.clientEmail.subject;
    XCTAssertGreaterThan([expectedMessageSubject length], 0);
    OCMExpect([emailComposeVCMock setSubject:expectedMessageSubject]);
    NSString *expectedMessageBody = sharerInstance.remoteConfiguration.clientEmail.body;
    XCTAssertGreaterThan([expectedMessageBody length], 0);
    OCMExpect([emailComposeVCMock setMessageBody:expectedMessageBody isHTML:NO]);
    OCMExpect([emailComposeVCMock setBccRecipients:recipients]);

    void (^myCompletionBlock)(MFMailComposeViewController *controller, MFMailComposeResult result) = ^void(MFMailComposeViewController *controller, MFMailComposeResult result) {};

    UIViewController *vc = [MAVESharer composeClientEmailInviteToRecipientEmails:recipients withCompletionBlock:myCompletionBlock];

    XCTAssertNotNil(vc);
    XCTAssertEqualObjects(vc, emailComposeVCMock);
    XCTAssertEqualObjects(sharerInstance.completionBlockClientEmail, myCompletionBlock);

    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(emailComposeVCMock);
    OCMVerifyAll(builderMock);
}

- (void)testComposeClientEmailInviteIfRecipientsNil {
    id emailComposeVCMock = OCMClassMock([MFMailComposeViewController class]);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    OCMExpect([builderMock MFMailComposeViewController]).andReturn(emailComposeVCMock);
    // should not set the recipients if nil
    [[emailComposeVCMock reject] setBccRecipients:[OCMArg any]];

    UIViewController *vc = [MAVESharer composeClientEmailInviteToRecipientEmails:nil withCompletionBlock:[OCMArg any]];

    XCTAssertNotNil(vc);
    OCMVerifyAll(emailComposeVCMock);
    OCMVerifyAll(builderMock);
}

- (void)testComposeClientEmailInviteReturnsNilIfCantSendEmail {
    id mailComposeVCMock = OCMClassMock([MFMailComposeViewController class]);
    OCMExpect([mailComposeVCMock canSendMail]).andReturn(NO);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    [[builderMock reject] sharerInstanceRetained];

    __block MFMailComposeResult returnedComposeResult;
    __block BOOL wasCalled = NO;
    UIViewController *vc = [MAVESharer composeClientEmailInviteToRecipientEmails:nil withCompletionBlock:^(MFMailComposeViewController *controller, MFMailComposeResult result) {
        returnedComposeResult = result;
        wasCalled = YES;
    }];
    XCTAssertNil(vc);
    XCTAssertTrue(wasCalled);
    XCTAssertEqual(returnedComposeResult, MFMailComposeResultFailed);
    OCMVerifyAll(builderMock);
}

- (void)testComposeClientEmailCompletionBlockSuccess {
    MAVESharer *sharer = [[MAVESharer alloc] initAndRetainSelf];
    __block MFMailComposeResult returnedResult;
    sharer.completionBlockClientEmail = ^void(MFMailComposeViewController *controller, MFMailComposeResult result) {
        returnedResult = result;
    };
    NSString *fakeToken = @"foo12398akj";
    id sharerMock = OCMPartialMock(sharer);
    OCMStub([sharerMock shareToken]).andReturn(fakeToken);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareWithShareType:MAVESharePageShareTypeClientEmail shareToken:fakeToken audience:nil]);

    id emailComposeVCMock = OCMClassMock([MFMailComposeViewController class]);
    // should not get dismissed, the caller is responsible for dismissing controller in the block
    [[emailComposeVCMock reject] dismissViewControllerAnimated:YES completion:nil];
    [sharer mailComposeController:emailComposeVCMock didFinishWithResult:MFMailComposeResultSent error:nil];

    XCTAssertEqual(returnedResult, MFMailComposeResultSent);
    XCTAssertNil(sharer.retainedSelf);
    XCTAssertNil(sharer.completionBlockClientEmail);
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(emailComposeVCMock);
}

- (void)testComposeClientEmailCompletionBlockCancelled {
    MAVESharer *sharer = [[MAVESharer alloc] initAndRetainSelf];
    __block MFMailComposeResult returnedResult;
    sharer.completionBlockClientEmail = ^void(MFMailComposeViewController *controller, MFMailComposeResult result) {
        returnedResult = result;
    };

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject] trackShareWithShareType:MAVESharePageShareTypeClientEmail shareToken:[OCMArg any] audience:nil];
    id emailComposeVCMock = OCMClassMock([MFMailComposeViewController class]);
    [[emailComposeVCMock reject] dismissViewControllerAnimated:YES completion:nil];

    [sharer mailComposeController:emailComposeVCMock didFinishWithResult:MFMailComposeResultCancelled error:nil];

    XCTAssertEqual(returnedResult, MFMailComposeResultCancelled);
    XCTAssertNil(sharer.retainedSelf);
    XCTAssertNil(sharer.completionBlockClientEmail);
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(emailComposeVCMock);
}

#pragma mark - native Facebook share widget

- (void)testComposeFacebookNativeShare {
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:MAVESharePageShareTypeFacebook]);

    // use a mock of the vc
    id socialComposeVCMock = OCMClassMock([SLComposeViewController class]);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    OCMExpect([builderMock SLComposeViewControllerForFacebook]).andReturn(socialComposeVCMock);
    MAVESharer *sharerInstance = [[MAVESharer alloc] init];
    OCMExpect([builderMock sharerInstanceRetained]).andReturn(sharerInstance);

    // expectations for content to pass to share view controller
    NSString *expectedText = sharerInstance.remoteConfiguration.facebookShare.text;
    OCMExpect([socialComposeVCMock setInitialText:expectedText]);
    NSString *expectedURLString = [MAVESharer shareLinkWithSubRouteLetter:@"f"];
    NSURL *expectedURL = [NSURL URLWithString:expectedURLString];
    OCMExpect([socialComposeVCMock addURL:expectedURL]);

    OCMExpect([socialComposeVCMock setCompletionHandler:[OCMArg any]]);

    void (^myCompletionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = ^void(SLComposeViewController *controller, SLComposeViewControllerResult result) {};

    // run code under test
    UIViewController *vc = [MAVESharer composeFacebookNativeShareWithCompletionBlock:myCompletionBlock];

    XCTAssertNotNil(vc);
    XCTAssertEqualObjects(vc, socialComposeVCMock);
    XCTAssertEqualObjects(sharerInstance.completionBlockFacebookNativeShare, myCompletionBlock);

    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(socialComposeVCMock);
    OCMVerifyAll(builderMock);
}

- (void)testComposeFacebookNativeCompletionSuccess {
    MAVESharer *sharer = [[MAVESharer alloc] initAndRetainSelf];
    __block SLComposeViewControllerResult returnedResult;
    sharer.completionBlockFacebookNativeShare = ^void(SLComposeViewController *controller, SLComposeViewControllerResult result) {
        returnedResult = result;
    };
    NSString *fakeToken = @"foo12398akk";
    id sharerMock = OCMPartialMock(sharer);
    OCMStub([sharerMock shareToken]).andReturn(fakeToken);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareWithShareType:MAVESharePageShareTypeFacebook shareToken:fakeToken audience:nil]);

    id composeVCMock = OCMClassMock([SLComposeViewController class]);
    // should not get dismissed, the caller is responsible for dismissing controller in the block
    [[composeVCMock reject] dismissViewControllerAnimated:YES completion:nil];

    // run code under test
    [sharer facebookNativeShareController:composeVCMock didFinishWithResult:SLComposeViewControllerResultDone];

    XCTAssertEqual(returnedResult, SLComposeViewControllerResultDone);
    XCTAssertNil(sharer.retainedSelf);
    XCTAssertNil(sharer.completionBlockFacebookNativeShare);
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(composeVCMock);
}

- (void)testComposeFacebookNativeCompletionCanceled {
    MAVESharer *sharer = [[MAVESharer alloc] initAndRetainSelf];
    __block SLComposeViewControllerResult returnedResult;
    sharer.completionBlockFacebookNativeShare = ^void(SLComposeViewController *controller, SLComposeViewControllerResult result) {
        returnedResult = result;
    };
    NSString *fakeToken = @"foo12398akk";
    id sharerMock = OCMPartialMock(sharer);
    OCMStub([sharerMock shareToken]).andReturn(fakeToken);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject ]trackShareWithShareType:MAVESharePageShareTypeFacebook shareToken:fakeToken audience:nil];

    id composeVCMock = OCMClassMock([SLComposeViewController class]);
    // should not get dismissed, the caller is responsible for dismissing controller in the block
    [[composeVCMock reject] dismissViewControllerAnimated:YES completion:nil];

    // run code under test
    [sharer facebookNativeShareController:composeVCMock didFinishWithResult:SLComposeViewControllerResultCancelled];

    XCTAssertEqual(returnedResult, SLComposeViewControllerResultCancelled);
    XCTAssertNil(sharer.retainedSelf);
    XCTAssertNil(sharer.completionBlockFacebookNativeShare);
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(composeVCMock);
}

#pragma mark - native Twitter share widget

- (void)testComposeTwitterNativeShare {
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:MAVESharePageShareTypeTwitter]);

    // use a mock of the vc
    id socialComposeVCMock = OCMClassMock([SLComposeViewController class]);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    OCMExpect([builderMock SLComposeViewControllerForTwitter]).andReturn(socialComposeVCMock);
    MAVESharer *sharerInstance = [[MAVESharer alloc] init];
    OCMExpect([builderMock sharerInstanceRetained]).andReturn(sharerInstance);

    // expectations for content to pass to share view controller
    NSString *expectedText = sharerInstance.remoteConfiguration.twitterShare.text;
    OCMExpect([socialComposeVCMock setInitialText:expectedText]);
    OCMExpect([socialComposeVCMock setCompletionHandler:[OCMArg any]]);

    void (^myCompletionBlock)(SLComposeViewController *controller, SLComposeViewControllerResult result) = ^void(SLComposeViewController *controller, SLComposeViewControllerResult result) {};


    // run code under test
    UIViewController *vc = [MAVESharer composeTwitterNativeShareWithCompletionBlock:myCompletionBlock];

    XCTAssertNotNil(vc);
    XCTAssertEqualObjects(vc, socialComposeVCMock);
    XCTAssertEqualObjects(sharerInstance.completionBlockTwitterNativeShare, myCompletionBlock);

    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(socialComposeVCMock);
    OCMVerifyAll(builderMock);
}

- (void)testComposeTwitterNativeCompletionSuccess {
    MAVESharer *sharer = [[MAVESharer alloc] initAndRetainSelf];
    __block SLComposeViewControllerResult returnedResult;
    sharer.completionBlockTwitterNativeShare = ^void(SLComposeViewController *controller, SLComposeViewControllerResult result) {
        returnedResult = result;
    };
    NSString *fakeToken = @"foo12398ako";
    id sharerMock = OCMPartialMock(sharer);
    OCMStub([sharerMock shareToken]).andReturn(fakeToken);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareWithShareType:MAVESharePageShareTypeTwitter shareToken:fakeToken audience:nil]);

    id composeVCMock = OCMClassMock([SLComposeViewController class]);
    // should not get dismissed, the caller is responsible for dismissing controller in the block
    [[composeVCMock reject] dismissViewControllerAnimated:YES completion:nil];

    // run code under test
    [sharer twitterNativeShareController:composeVCMock didFinishWithResult:SLComposeViewControllerResultDone];

    XCTAssertEqual(returnedResult, SLComposeViewControllerResultDone);
    XCTAssertNil(sharer.retainedSelf);
    XCTAssertNil(sharer.completionBlockTwitterNativeShare);
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(composeVCMock);
}

- (void)testComposeTwitterNativeCompletionCanceled {
    MAVESharer *sharer = [[MAVESharer alloc] initAndRetainSelf];
    __block SLComposeViewControllerResult returnedResult;
    sharer.completionBlockTwitterNativeShare = ^void(SLComposeViewController *controller, SLComposeViewControllerResult result) {
        returnedResult = result;
    };
    NSString *fakeToken = @"foo12398ako";
    id sharerMock = OCMPartialMock(sharer);
    OCMStub([sharerMock shareToken]).andReturn(fakeToken);

    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    [[apiInterfaceMock reject] trackShareWithShareType:MAVESharePageShareTypeTwitter shareToken:fakeToken audience:nil];

    id composeVCMock = OCMClassMock([SLComposeViewController class]);
    // should not get dismissed, the caller is responsible for dismissing controller in the block
    [[composeVCMock reject] dismissViewControllerAnimated:YES completion:nil];

    // run code under test
    [sharer twitterNativeShareController:composeVCMock didFinishWithResult:SLComposeViewControllerResultCancelled];

    XCTAssertEqual(returnedResult, SLComposeViewControllerResultCancelled);
    XCTAssertNil(sharer.retainedSelf);
    XCTAssertNil(sharer.completionBlockTwitterNativeShare);
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(composeVCMock);
}

#pragma mark - Clipboard share

- (void)testClipboardShare {
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:MAVESharePageShareTypeClipboard]);

    // use a mock of the pasteboard
    id pasteboardMock = OCMClassMock([UIPasteboard class]);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    OCMExpect([builderMock UIPasteboard]).andReturn(pasteboardMock);
    MAVESharer *sharerInstance = [[MAVESharer alloc] init];
    OCMExpect([builderMock sharerInstanceRetained]).andReturn(sharerInstance);
    id sharerMock = OCMPartialMock(sharerInstance);
    OCMExpect([sharerMock resetShareToken]);
    OCMExpect([sharerMock releaseSelf]);

    // expectations for content to pass to share view controller
    NSString *expectedText = sharerInstance.remoteConfiguration.clipboardShare.text;
    OCMExpect([pasteboardMock setString:expectedText]);

    // run code under test
    [MAVESharer composePasteboardShare];

    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(pasteboardMock);
    OCMVerifyAll(builderMock);
    OCMVerifyAll(sharerMock);
}

#pragma mark - Helpers for building share content
- (void)testShareToken {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVEShareToken *tokenObj = [[MAVEShareToken alloc] init];
    tokenObj.shareToken = @"blahasdf";
    id mock = OCMClassMock([MAVERemoteObjectBuilder class]);
    [MaveSDK sharedInstance].shareTokenBuilder = mock;
    OCMExpect([mock createObjectSynchronousWithTimeout:0]).andReturn(tokenObj);

    NSString *token = [MAVESharer shareToken];
    OCMVerifyAll(mock);
    XCTAssertEqualObjects(token, @"blahasdf");
}

- (void)testShareTokenNilWhenBuilderIsNil {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    [MaveSDK sharedInstance].shareTokenBuilder = nil;

    NSString *shareToken = [MAVESharer shareToken];
    XCTAssertNil(shareToken);
}

- (void)testShareLinkBaseURLWhenCustom {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo124"];
    MAVERemoteConfiguration *config = [[MAVERemoteConfiguration alloc] init];
    config.customSharePage = [[MAVERemoteConfigurationCustomSharePage alloc] init];
    config.customSharePage.inviteLinkBaseURL = @"http://foo.example.com";

    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock remoteConfiguration]).andReturn(config);

    NSString *url = [MAVESharer shareLinkBaseURL];
    XCTAssertEqualObjects(url, @"http://foo.example.com/");
    OCMVerifyAll(maveMock);
}

- (void)testShareLinkBaseURLWhenUsingDefault {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo124"];
    MAVERemoteConfiguration *config = [[MAVERemoteConfiguration alloc] init];
    config.customSharePage = [[MAVERemoteConfigurationCustomSharePage alloc] init];
    config.customSharePage.inviteLinkBaseURL = nil;

    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock remoteConfiguration]).andReturn(config);

    NSString *url = [MAVESharer shareLinkBaseURL];
    XCTAssertEqualObjects(url, MAVEShortLinkBaseURL);
    XCTAssertEqualObjects(url, @"test-appjoin-us/");
    OCMVerifyAll(maveMock);
}

- (void)testBuildShareLink {
    NSString *expectedLink = [NSString stringWithFormat:@"%@d/blahtok", MAVEShortLinkBaseURL];
    MAVESharer *sharer = [[MAVESharer alloc] init];
    id mock = OCMPartialMock(sharer);
    OCMStub([mock shareToken]).andReturn(@"blahtok");
    NSString *link = [MAVESharer shareLinkWithSubRouteLetter:@"d"];
    XCTAssertEqualObjects(link, expectedLink);
}

- (void)testBuildShareLinkWhenUsingMaveLinksWithCustomDomain {
    NSString *expectedLink = @"http://foo.example.com/d/blahtok2";
    MAVESharer *sharer = [[MAVESharer alloc] init];
    id mock = OCMPartialMock(sharer);
    OCMStub([mock shareToken]).andReturn(@"blahtok2");
    OCMStub([mock shareLinkBaseURL]).andReturn(@"http://foo.example.com/");
    NSString *link = [MAVESharer shareLinkWithSubRouteLetter:@"d"];
    XCTAssertEqualObjects(link, expectedLink);
}

- (void)testBuildLinkWhenNotUsingMaveLinks {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Dan" lastName:@"Foo"];
    user.inviteLinkDestinationURL = @"http://example.com/abcd";
    user.wrapInviteLink = NO;
    [MaveSDK sharedInstance].userData = user;

    NSString *link = [MAVESharer shareLinkWithSubRouteLetter:@"a"];
    XCTAssertEqualObjects(link, @"http://example.com/abcd");
}

- (void)testBuildShareLinkWhenNoShareToken {
    NSString *expectedLink = [NSString stringWithFormat:@"%@o/d/%@", MAVEShortLinkBaseURL,
                              [MAVEClientPropertyUtils urlSafeBase64ApplicationID]];
    MAVESharer *sharer = [[MAVESharer alloc] init];
    id mock = OCMPartialMock(sharer);
    OCMStub([mock shareToken]).andReturn(nil);

    NSString *link = [MAVESharer shareLinkWithSubRouteLetter:@"d"];

    XCTAssertEqualObjects(link, expectedLink);
}

- (void)testResetShareToken {
    MAVERemoteObjectBuilder *builderInitial = [MaveSDK sharedInstance].shareTokenBuilder;

    id stClassMock = OCMClassMock([MAVEShareToken class]);
    OCMExpect([stClassMock clearUserDefaults]);

    [MAVESharer resetShareToken];

    OCMVerifyAll(stClassMock);
    XCTAssertNotEqualObjects([MaveSDK sharedInstance].shareTokenBuilder, builderInitial);
}

- (void)testBuildShareCopyWhenCopyIsNormal {
    id mock = OCMClassMock([MAVESharer class]);
    OCMExpect([mock shareLinkWithSubRouteLetter:@"d"]).andReturn(@"fakelink");

    NSString *text = [MAVESharer shareCopyFromCopy:@"foo"
                              andLinkWithSubRouteLetter:@"d"];

    NSString *expectedText = @"foo fakelink";

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(text, expectedText);
}

- (void)testBuildShareCopyWhenCopyEndsInSpace {
    id mock = OCMClassMock([MAVESharer class]);
    OCMStub([mock shareLinkWithSubRouteLetter:@"d"]).andReturn(@"fakelink");

    NSString *text = [MAVESharer shareCopyFromCopy:@"foo "
                              andLinkWithSubRouteLetter:@"d"];

    NSString *expectedText = @"foo fakelink";
    XCTAssertEqualObjects(text, expectedText);

    // newline should count as a space too
    text = [MAVESharer shareCopyFromCopy:@"foo\n"
                    andLinkWithSubRouteLetter:@"d"];

    expectedText = @"foo\nfakelink";
    XCTAssertEqualObjects(text, expectedText);
}

- (void)testBuildShareCopyWhenCopyIsEmpty {
    id mock = OCMClassMock([MAVESharer class]);
    OCMExpect([mock shareLinkWithSubRouteLetter:@"d"]).andReturn(@"fakelink");

    NSString *text = [MAVESharer shareCopyFromCopy:nil
                              andLinkWithSubRouteLetter:@"d"];

    NSString *expectedText = @"fakelink";
    
    OCMVerifyAll(mock);
    XCTAssertEqualObjects(text, expectedText);
}

#pragma mark - Tests for setup share token
- (void)testSetupShareTokenStoresLinkDetailsAndSetsUpShareTokenBuilder {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertNil([MaveSDK sharedInstance].shareTokenBuilder);
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Dan" lastName:@"Foo"];
    user.inviteLinkDestinationURL = @"https://example.com/1";
    user.wrapInviteLink = YES;
    [MaveSDK sharedInstance].userData = user;

    id maveShareToken = OCMClassMock([MAVEShareToken class]);
    id someObj = [[NSObject alloc] init];
    OCMExpect([maveShareToken remoteBuilder]).andReturn(someObj);

    // run method under test
    [MAVESharer setupShareToken];

    NSData *_ldData = [[NSUserDefaults standardUserDefaults] objectForKey:MAVEUserDefaultsKeyLinkDetails];
    XCTAssertNotNil(_ldData);
    NSDictionary *storedLinkDetails = [NSJSONSerialization JSONObjectWithData:_ldData options:0 error:nil];
    XCTAssertNotNil(storedLinkDetails);
    XCTAssertEqualObjects([user serializeLinkDetails], storedLinkDetails);

    XCTAssertEqualObjects([MaveSDK sharedInstance].shareTokenBuilder, someObj);
    OCMVerifyAll(maveShareToken);
}

- (void)testSetupShareTokenClearsExistingShareTokenIfDetailsDifferent {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"foobar" forKey:MAVEUserDefaultsKeyShareToken];
    [defaults setObject:[NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil] forKey:MAVEUserDefaultsKeyLinkDetails];

    id maveShareToken = OCMClassMock([MAVEShareToken class]);
    OCMStub([maveShareToken remoteBuilder]);

    // run method under test
    [MAVESharer setupShareToken];

    NSString *storedToken = [defaults objectForKey:MAVEUserDefaultsKeyShareToken];
    XCTAssertNil(storedToken);
}

- (void)testSetupShareTokenDoesntClearExistingShareTokenIfDetailsSame {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];

    // Manually store the link details for the current user object,
    // then when the setup share token method looks up the stored linke
    // details they won't have changed so it won't clear share token user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Danny" lastName:@"Foo"];
    user.wrapInviteLink = YES;
    user.inviteLinkDestinationURL = @"https://example.com/bar";
    user.customData = @{@"foo": @"bar"};
    [MaveSDK sharedInstance].userData = user;
    [defaults setObject:[NSJSONSerialization dataWithJSONObject:[user serializeLinkDetails] options:0 error:nil] forKey:MAVEUserDefaultsKeyLinkDetails];
    [defaults setObject:@"foobar8127" forKey:MAVEUserDefaultsKeyShareToken];

    id maveShareToken = OCMClassMock([MAVEShareToken class]);
    OCMStub([maveShareToken remoteBuilder]);

    // run method under test
    [MAVESharer setupShareToken];

    NSString *storedToken = [defaults objectForKey:MAVEUserDefaultsKeyShareToken];
    XCTAssertNotNil(storedToken);
    XCTAssertEqualObjects(storedToken, @"foobar8127");
}

- (void)testSetupShareTokenDoesNothingIfNotUsingMaveLinks {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertNil([MaveSDK sharedInstance].shareTokenBuilder);
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"1" firstName:@"Dan" lastName:@"Foo"];
    user.inviteLinkDestinationURL = @"https://example.com/1";
    user.wrapInviteLink = NO;
    [MaveSDK sharedInstance].userData = user;

    [MAVESharer setupShareToken];

    XCTAssertNil([MaveSDK sharedInstance].shareTokenBuilder);
}

- (void)testSetupShareTokenDoesNothingIfShareTokenBuilderAlreadyExists {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    MAVERemoteObjectBuilder *emptyBuilder = [[MAVERemoteObjectBuilder alloc] init];
    [MaveSDK sharedInstance].shareTokenBuilder = emptyBuilder;

    [MAVESharer setupShareToken];

    XCTAssertEqualObjects([MaveSDK sharedInstance].shareTokenBuilder, emptyBuilder);
}

@end
