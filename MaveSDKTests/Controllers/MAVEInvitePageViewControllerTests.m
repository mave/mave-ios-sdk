//
//  MAVEInvitePageViewControllerTests.m
//  MaveSDK
//
//  Created by dannycosson on 10/14/14.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MaveSDK.h"
#import "MAVEUserData.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEHTTPManager.h"
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEInviteMessageView.h"

@interface MAVEInvitePageViewControllerTests : XCTestCase

@end

@implementation MAVEInvitePageViewControllerTests

- (void)setUp {
    [super setUp];
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"1231234"];
    [MaveSDK sharedInstance].userData = [[MAVEUserData alloc] init];
    [MaveSDK sharedInstance].userData.userID = @"foo";
}

- (void)tearDown {
    [super tearDown];
}

//
- (void)testRespondAsAdditionalTableViewDelegate {
    id mock = [OCMockObject mockForClass:[MAVEInviteMessageView class]];
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    vc.inviteMessageViewController.messageView = mock;
    OCMExpect([mock updateNumberPeopleSelected:2]);
    [vc ABTableViewControllerNumberSelectedChanged:2];
    OCMVerify(mock);
}

- (void)testDismissalBlockCalled {
    __block unsigned int numSent = 0;
    [MaveSDK sharedInstance].invitePageDismissalBlock =
        ^void(UIViewController *viewController,
              unsigned int numberOfInvitesSent) {
        numSent = numberOfInvitesSent;
    };
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    XCTAssertEqual(numSent, 0);
    [vc dismissSelf:3];
    XCTAssertEqual(numSent, 3);
}

//
// Sending requests
//
- (void)testSendInvites {
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    [vc loadView];
    [vc viewDidLoad];
    
    // Setup content for invites
    NSString *inviteMessage = @"This was the text typed in";
    NSArray *invitePhones = @[@"18085551234"];
    vc.ABTableViewController.selectedPhoneNumbers = [[NSMutableSet alloc] initWithArray: invitePhones];
    vc.inviteMessageViewController.messageView.textField.text = inviteMessage;

    // Create a mock http manager & stub the singleton object to use it
    id mockHTTPManager = [OCMockObject partialMockForObject:[MaveSDK sharedInstance].HTTPManager];

    [[mockHTTPManager expect] sendInvitesWithPersons:invitePhones
                                            message:inviteMessage
                                              userId:[MaveSDK sharedInstance].userData.userID
                                       completionBlock:[OCMArg any]];
    [vc sendInvites];
    [mockHTTPManager verify];
}



- (void)testViewDidLoadSendsInvitePageViewedEvent {
    NSString *userId = @"1239sdf";
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];
    MAVEUserData *userData = [[MAVEUserData alloc] initWithUserID:userId firstName:@"Dan" lastName:@"Foo" email:@"dan@example.com" phone:@"18085551234"];
    [MaveSDK sharedInstance].userData = userData;
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    id mockHTTPManager = [OCMockObject partialMockForObject: [MaveSDK sharedInstance].HTTPManager];
    [[mockHTTPManager expect] trackInvitePageOpenRequest:userData];
    
    [vc viewDidLoad];
    
    [mockHTTPManager verify];
}
@end