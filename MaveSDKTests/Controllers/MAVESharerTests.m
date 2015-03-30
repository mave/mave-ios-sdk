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
    NSString *expectedMessageText = [sharerInstance shareCopyFromCopy:sharerInstance.remoteConfiguration.clientSMS.text andLinkWithSubRouteLetter:@"s"];
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
    NSString *expectedMessageText = [sharerInstance.remoteConfiguration.clientSMS.text stringByAppendingString:@" http://example.com/unwrapped/link"];
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

- (void)testComposeClientSMSInviteReturnsNilIfCantSendSMS {
    XCTAssertFalse([MFMessageComposeViewController canSendText]);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    [[builderMock reject] sharerInstanceRetained];

    UIViewController *vc = [MAVESharer composeClientSMSInviteToRecipientPhones:nil completionBlock:nil];
    XCTAssertNil(vc);
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
    NSString *expectedMessageSubject = sharerInstance.remoteConfiguration.clientEmail.subject;
    XCTAssertGreaterThan([expectedMessageSubject length], 0);
    OCMExpect([emailComposeVCMock setSubject:expectedMessageSubject]);
    NSString *expectedMessageBody = [sharerInstance shareCopyFromCopy:sharerInstance.remoteConfiguration.clientEmail.body andLinkWithSubRouteLetter:@"e"];
    XCTAssertGreaterThan([expectedMessageBody length], 0);
    OCMExpect([emailComposeVCMock setMessageBody:expectedMessageBody isHTML:NO]);

    void (^myCompletionBlock)(MFMailComposeViewController *controller, MFMailComposeResult result) = ^void(MFMailComposeViewController *controller, MFMailComposeResult result) {};

    UIViewController *vc = [MAVESharer composeClientEmailWithCompletionBlock:myCompletionBlock];

    XCTAssertNotNil(vc);
    XCTAssertEqualObjects(vc, emailComposeVCMock);
    XCTAssertEqualObjects(sharerInstance.completionBlockClientEmail, myCompletionBlock);

    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(emailComposeVCMock);
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
    OCMExpect([builderMock SLComposeViewController]).andReturn(socialComposeVCMock);
    MAVESharer *sharerInstance = [[MAVESharer alloc] init];
    OCMExpect([builderMock sharerInstanceRetained]).andReturn(sharerInstance);

    // expectations for content to pass to share view controller
    NSString *expectedText = sharerInstance.remoteConfiguration.facebookShare.text;
    OCMExpect([socialComposeVCMock setInitialText:expectedText]);
    NSString *expectedURLString = [sharerInstance shareLinkWithSubRouteLetter:@"f"];
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

}

#pragma mark - native Twitter share widget

- (void)testComposeTwitterNativeShare {
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    OCMExpect([apiInterfaceMock trackShareActionClickWithShareType:MAVESharePageShareTypeTwitter]);

    // use a mock of the vc
    id socialComposeVCMock = OCMClassMock([SLComposeViewController class]);
    id builderMock = OCMClassMock([MAVESharerViewControllerBuilder class]);
    OCMExpect([builderMock SLComposeViewController]).andReturn(socialComposeVCMock);
    MAVESharer *sharerInstance = [[MAVESharer alloc] init];
    OCMExpect([builderMock sharerInstanceRetained]).andReturn(sharerInstance);

    // expectations for content to pass to share view controller
    NSString *expectedText = [sharerInstance shareCopyFromCopy:sharerInstance.remoteConfiguration.twitterShare.text andLinkWithSubRouteLetter:@"t"];
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

}

#pragma mark - Helpers for building share content
- (void)testShareToken {
    MAVESharer *sharer = [[MAVESharer alloc] init];
    MAVEShareToken *tokenObj = [[MAVEShareToken alloc] init];
    tokenObj.shareToken = @"blahasdf";

    id mock = OCMPartialMock([MaveSDK sharedInstance].shareTokenBuilder);
    OCMExpect([mock createObjectSynchronousWithTimeout:0]).andReturn(tokenObj);
    NSString *token = [sharer shareToken];
    OCMVerifyAll(mock);
    XCTAssertEqualObjects(token, @"blahasdf");
    [mock stopMocking];
}


- (void)testBuildShareLink {
    NSString *expectedLink = [NSString stringWithFormat:@"%@d/blahtok", MAVEShortLinkBaseURL];
    MAVESharer *sharer = [[MAVESharer alloc] init];
    id mock = OCMPartialMock(sharer);
    OCMStub([mock shareToken]).andReturn(@"blahtok");
    NSString *link = [sharer shareLinkWithSubRouteLetter:@"d"];
    XCTAssertEqualObjects(link, expectedLink);
}

- (void)testBuildShareLinkWhenNoShareToken {
    NSString *expectedLink = [NSString stringWithFormat:@"%@o/d/%@", MAVEShortLinkBaseURL,
                              [MAVEClientPropertyUtils urlSafeBase64ApplicationID]];
    MAVESharer *sharer = [[MAVESharer alloc] init];
    id mock = OCMPartialMock(sharer);
    OCMStub([mock shareToken]).andReturn(nil);

    NSString *link = [sharer shareLinkWithSubRouteLetter:@"d"];

    XCTAssertEqualObjects(link, expectedLink);
}

- (void)testResetShareToken {
    MAVESharer *sharer = [[MAVESharer alloc] init];
    MAVERemoteObjectBuilder *builderInitial = [MaveSDK sharedInstance].shareTokenBuilder;

    id stClassMock = OCMClassMock([MAVEShareToken class]);
    OCMExpect([stClassMock clearUserDefaults]);

    [sharer resetShareToken];

    OCMVerifyAll(stClassMock);
    XCTAssertNotEqualObjects([MaveSDK sharedInstance].shareTokenBuilder, builderInitial);
}

- (void)testBuildShareCopyWhenCopyIsNormal {
    MAVESharer *sharer = [[MAVESharer alloc] init];
    id mock = OCMPartialMock(sharer);
    OCMExpect([mock shareLinkWithSubRouteLetter:@"d"]).andReturn(@"fakelink");

    NSString *text = [sharer shareCopyFromCopy:@"foo"
                              andLinkWithSubRouteLetter:@"d"];

    NSString *expectedText = @"foo fakelink";

    OCMVerifyAll(mock);
    XCTAssertEqualObjects(text, expectedText);
}

- (void)testBuildShareCopyWhenCopyEndsInSpace {
    MAVESharer *sharer = [[MAVESharer alloc] init];
    id mock = OCMPartialMock(sharer);
    OCMStub([mock shareLinkWithSubRouteLetter:@"d"]).andReturn(@"fakelink");

    NSString *text = [sharer shareCopyFromCopy:@"foo "
                              andLinkWithSubRouteLetter:@"d"];

    NSString *expectedText = @"foo fakelink";
    XCTAssertEqualObjects(text, expectedText);

    // newline should count as a space too
    text = [sharer shareCopyFromCopy:@"foo\n"
                    andLinkWithSubRouteLetter:@"d"];

    expectedText = @"foo\nfakelink";
    XCTAssertEqualObjects(text, expectedText);
}

- (void)testBuildShareCopyWhenCopyIsEmpty {
    MAVESharer *sharer = [[MAVESharer alloc] init];
    id mock = OCMPartialMock(sharer);
    OCMExpect([mock shareLinkWithSubRouteLetter:@"d"]).andReturn(@"fakelink");

    NSString *text = [sharer shareCopyFromCopy:nil
                              andLinkWithSubRouteLetter:@"d"];

    NSString *expectedText = @"fakelink";
    
    OCMVerifyAll(mock);
    XCTAssertEqualObjects(text, expectedText);
}

@end
