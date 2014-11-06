//
//  GRKInvitePageViewControllerTests.m
//  GrowthKit
//
//  Created by dannycosson on 10/14/14.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "GrowthKit.h"
#import "GRKUserData.h"
#import "GRKInvitePageViewController.h"
#import "GRKHTTPManager.h"
#import "GRKDisplayOptionsFactory.h"
#import "GRKInviteMessageView.h"

@interface GRKInvitePageViewControllerTests : XCTestCase

@end

@implementation GRKInvitePageViewControllerTests

- (void)setUp {
    [super setUp];
    [GrowthKit resetSharedInstanceForTesting];
    [GrowthKit setupSharedInstanceWithApplicationID:@"1231234"];
    [GrowthKit sharedInstance].userData = [[GRKUserData alloc] init];
    [GrowthKit sharedInstance].userData.userID = @"foo";
}

- (void)tearDown {
    [super tearDown];
}

//
- (void)testRespondAsAdditionalTableViewDelegate {
    id mock = [OCMockObject mockForClass:[GRKInviteMessageView class]];
    GRKInvitePageViewController *vc = [[GRKInvitePageViewController alloc] init];
    vc.inviteMessageViewController.messageView = mock;
    OCMExpect([mock updateNumberPeopleSelected:2]);
    [vc ABTableViewControllerNumberSelectedChanged:2];
    OCMVerify(mock);
}

//
// Sending requests
//
- (void)testSendInvites {
    GRKInvitePageViewController *vc = [[GRKInvitePageViewController alloc] init];
    [vc loadView];
    [vc viewDidLoad];
    
    // Setup content for invites
    NSString *inviteMessage = @"This was the text typed in";
    NSArray *invitePhones = @[@"18085551234"];
    vc.ABTableViewController.selectedPhoneNumbers = [[NSMutableSet alloc] initWithArray: invitePhones];
    vc.inviteMessageViewController.messageView.textField.text = inviteMessage;

    // Create a mock http manager & stub the singleton object to use it
    id mockHTTPManager = [OCMockObject partialMockForObject:[GrowthKit sharedInstance].HTTPManager];

    [[mockHTTPManager expect] sendInvitesWithPersons:invitePhones
                                            message:inviteMessage
                                              userId:[GrowthKit sharedInstance].userData.userID
                                       completionBlock:[OCMArg any]];
    [vc sendInvites];
    [mockHTTPManager verify];
}

- (void)testViewDidLoadSendsInvitePageViewedEvent {
    NSString *userId = @"1239sdf";
    [GrowthKit setupSharedInstanceWithApplicationID:@"appid1"];
    GRKUserData *userData = [[GRKUserData alloc] initWithUserID:userId firstName:@"Dan" lastName:@"Foo" email:@"dan@example.com" phone:@"18085551234"];
    [GrowthKit sharedInstance].userData = userData;
    GRKInvitePageViewController *vc = [[GRKInvitePageViewController alloc] init];
    id mockHTTPManager = [OCMockObject partialMockForObject: [GrowthKit sharedInstance].HTTPManager];
    [[mockHTTPManager expect] trackInvitePageOpenRequest:userData];
    
    [vc viewDidLoad];
    
    [mockHTTPManager verify];
}
@end