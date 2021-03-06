//
//  MAVEInviteMessageContainerViewTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 11/16/14.
//
//

#import <UIKit/UIKit.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "MAVEInvitePageBottomActionContainerView.h"

@interface MAVEInvitePageBottomActionContainerViewTests : XCTestCase

@end

@implementation MAVEInvitePageBottomActionContainerViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitAsServerSideSMSInviteMessageView {
    MAVEInvitePageBottomActionContainerView *view = [[MAVEInvitePageBottomActionContainerView alloc] initWithSMSInviteSendMethod:MAVESMSInviteSendMethodServerSide];
    XCTAssertEqual(view.smsInviteSendMethod, MAVESMSInviteSendMethodServerSide);
    XCTAssertNotNil(view.inviteMessageView);
    XCTAssertNotNil(view.sendingInProgressView);
    XCTAssertNotNil(view.clientSideBottomActionView);
    XCTAssertTrue([view.inviteMessageView isDescendantOfView:view]);
    XCTAssertTrue([view.sendingInProgressView isDescendantOfView:view]);
    XCTAssertFalse([view.clientSideBottomActionView isDescendantOfView:view]);
    XCTAssertFalse(view.inviteMessageView.hidden);
    XCTAssertTrue(view.sendingInProgressView.hidden);

    // height method should call the invite message view's height method
    id serverSideInviteMessageViewMock = OCMPartialMock(view.inviteMessageView);
    OCMExpect([serverSideInviteMessageViewMock computeHeightWithWidth:123]).andReturn(456);

    CGFloat height = [view heightForViewWithWidth:123];

    XCTAssertEqual(height, 456);
    OCMVerifyAll(serverSideInviteMessageViewMock);
}

- (void)testInitAsClientGroupSMSMessageView {
    MAVEInvitePageBottomActionContainerView *view = [[MAVEInvitePageBottomActionContainerView alloc] initWithSMSInviteSendMethod:MAVESMSInviteSendMethodClientSideGroup];
    XCTAssertEqual(view.smsInviteSendMethod, MAVESMSInviteSendMethodClientSideGroup);
    XCTAssertNotNil(view.inviteMessageView);
    XCTAssertNotNil(view.sendingInProgressView);
    XCTAssertNotNil(view.clientSideBottomActionView);
    XCTAssertFalse([view.inviteMessageView isDescendantOfView:view]);
    XCTAssertFalse([view.sendingInProgressView isDescendantOfView:view]);
    XCTAssertTrue([view.clientSideBottomActionView isDescendantOfView:view]);

    // height method should call the underlying height method
    id clientSideBottomActionViewMock = OCMPartialMock(view.clientSideBottomActionView);
    OCMExpect([clientSideBottomActionViewMock heightOfSelf]).andReturn(124);

    CGFloat height = [view heightForViewWithWidth:123];

    XCTAssertEqual(height, 124);
    OCMVerifyAll(clientSideBottomActionViewMock);
}

- (void)testAddTargetToButtonForServerSMSMethod {
    MAVEInvitePageBottomActionContainerView *view = [[MAVEInvitePageBottomActionContainerView alloc] initWithSMSInviteSendMethod:MAVESMSInviteSendMethodServerSide];
    id sendButtonMock = OCMPartialMock(view.inviteMessageView.sendButton);
    NSObject *fakeTarget = [[NSObject alloc] init];
    SEL fakeSelector = @selector(tearDown);
    OCMExpect([sendButtonMock addTarget:fakeTarget action:fakeSelector forControlEvents:UIControlEventTouchUpInside]);

    [view addToSendButtonTarget:fakeTarget andAction:fakeSelector];

    OCMVerifyAll(sendButtonMock);
}

- (void)testAddTargetToButtonForClientSideGroupSMSMethod {
    MAVEInvitePageBottomActionContainerView *view = [[MAVEInvitePageBottomActionContainerView alloc] initWithSMSInviteSendMethod:MAVESMSInviteSendMethodClientSideGroup];
    id sendButtonMock = OCMPartialMock(view.clientSideBottomActionView.sendButton);
    NSObject *fakeTarget = [[NSObject alloc] init];
    SEL fakeSelector = @selector(tearDown);
    OCMExpect([sendButtonMock addTarget:fakeTarget action:fakeSelector forControlEvents:UIControlEventTouchUpInside]);

    [view addToSendButtonTarget:fakeTarget andAction:fakeSelector];

    OCMVerifyAll(sendButtonMock);
}

- (void)testUpdateNumberPeopleSelectedForServerSideSMSMethod {
    MAVEInvitePageBottomActionContainerView *view = [[MAVEInvitePageBottomActionContainerView alloc] initWithSMSInviteSendMethod:MAVESMSInviteSendMethodServerSide];
    id inviteMessageViewMock = OCMPartialMock(view.inviteMessageView);
    OCMExpect([inviteMessageViewMock updateNumberPeopleSelected:123]);

    [view updateNumberPeopleSelected:123];

    OCMVerifyAll(inviteMessageViewMock);
}

- (void)testUpdateNumberPeopleSelectedForClientSideGroupSMSMethod {
    MAVEInvitePageBottomActionContainerView *view = [[MAVEInvitePageBottomActionContainerView alloc] initWithSMSInviteSendMethod:MAVESMSInviteSendMethodClientSideGroup];
    XCTAssertEqual(view.clientSideBottomActionView.numberSelected, 0);

    [view updateNumberPeopleSelected:123];

    XCTAssertEqual(view.clientSideBottomActionView.numberSelected, 123);
}

- (void)testServerSMSSwitchToSendingInProgressView {
    MAVEInvitePageBottomActionContainerView *view = [[MAVEInvitePageBottomActionContainerView alloc] initWithSMSInviteSendMethod:MAVESMSInviteSendMethodServerSide];
    id sendingInProgressViewMock = [OCMockObject partialMockForObject:view.sendingInProgressView];
    [[sendingInProgressViewMock expect] startTimedProgress];

    [view makeSendingInProgressViewActive];

    [sendingInProgressViewMock verify];
    XCTAssertTrue(view.inviteMessageView.hidden);
    XCTAssertFalse(view.sendingInProgressView.hidden);
}

- (void)testServerSMSSwitchToInviteMessageView {
    MAVEInvitePageBottomActionContainerView *view = [[MAVEInvitePageBottomActionContainerView alloc] initWithSMSInviteSendMethod:MAVESMSInviteSendMethodServerSide];
    [view makeSendingInProgressViewActive];
    [view makeInviteMessageViewActive];
    XCTAssertFalse(view.inviteMessageView.hidden);
    XCTAssertTrue(view.sendingInProgressView.hidden);
    
}

@end
