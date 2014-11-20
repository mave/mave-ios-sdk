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
#import "MAVEInviteMessageContainerView.h"

@interface MAVEInviteMessageContainerViewTests : XCTestCase

@end

@implementation MAVEInviteMessageContainerViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitAsMessageView {
    MAVEInviteMessageContainerView *view = [[MAVEInviteMessageContainerView alloc] init];
    XCTAssertNotNil(view.inviteMessageView);
    XCTAssertNotNil(view.sendingInProgressView);

    id sendingInProgressViewMock = [OCMockObject partialMockForObject:view.sendingInProgressView];
    XCTAssertFalse(view.inviteMessageView.hidden);
    XCTAssertTrue(view.sendingInProgressView.hidden);
    [sendingInProgressViewMock verify];
}

- (void)testSwitchToSendingInProgressView {
    MAVEInviteMessageContainerView *view = [[MAVEInviteMessageContainerView alloc] init];
    [view makeSendingInProgressViewActive];
    XCTAssertTrue(view.inviteMessageView.hidden);
    XCTAssertFalse(view.sendingInProgressView.hidden);
}

- (void)testSwitchToInviteMessageView {
    MAVEInviteMessageContainerView *view = [[MAVEInviteMessageContainerView alloc] init];
    [view makeSendingInProgressViewActive];
    [view makeInviteMessageViewActive];
    XCTAssertFalse(view.inviteMessageView.hidden);
    XCTAssertTrue(view.sendingInProgressView.hidden);
    
}

@end
