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
