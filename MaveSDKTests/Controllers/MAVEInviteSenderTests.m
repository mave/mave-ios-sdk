//
//  MAVEInviteSenderTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 7/31/15.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "MAVEInviteSender.h"
#import "MaveSDK.h"
#import "MAVEABPerson.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEInviteSenderTests : XCTestCase

@end

@implementation MAVEInviteSenderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSendInviteToPerson {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo234"];
    MAVEUserData *user = [[MAVEUserData alloc] initWithUserID:@"123" firstName:@"Foo" lastName:@"Example"];
    user.inviteLinkDestinationURL = @"http://example.com/invite";
    user.wrapInviteLink = NO;
    user.customData = @{@"value": @"foo"};
    [[MaveSDK sharedInstance] identifyUser:user];
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);

    MAVEABPerson *p0 = [[MAVEABPerson alloc] init];
    MAVEContactEmail *email0 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    p0.emailObjects = @[email0, email1];
    OCMExpect([apiInterfaceMock sendInvitesToRecipients:@[p0] smsCopy:[MaveSDK sharedInstance].defaultSMSMessageText senderUserID:@"123" inviteLinkDestinationURL:user.inviteLinkDestinationURL wrapInviteLink:NO customData:user.customData completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(NSError *error, NSDictionary *responseData)  = obj;
        completionBlock(nil, nil);
        return YES;
    }]]);

    MAVEInviteSender *sender = [[MAVEInviteSender alloc] init];
    __block BOOL sentOK = NO;
    [sender invitePerson:p0 withCompletionBlock:^(BOOL success) {
        sentOK = success;
    }];

    XCTAssertTrue(sentOK);
    OCMVerifyAll(apiInterfaceMock);
    // Since neither contact identifier (email) was already marked as selected
    // this method should have marked the first one as selected
    XCTAssertTrue(email0.selected);
}



@end
