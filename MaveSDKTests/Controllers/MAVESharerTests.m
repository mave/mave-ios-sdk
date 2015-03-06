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

@interface MAVESharerTests : XCTestCase

@end

@implementation MAVESharerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

    // No idea why but this simple class method mock is not working at all
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
