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
#import "GRKInvitePageViewController.h"
#import "GRKHTTPManager.h"

@interface GRKInvitePageViewControllerTests : XCTestCase

@end

@implementation GRKInvitePageViewControllerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSendInvites {
    [GrowthKit setupSharedInstanceWithApplicationID:@"1231234"];
    [GrowthKit sharedInstance].currentUserId = @"foo";
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
                                       completionBlock:[OCMArg any]];
    [vc sendInvites];

    [mockHTTPManager verify];
}

- (void)testViewDidLoadSendsInvitePageViewedEvent {
    NSString *userId = @"1239sdf";
    [GrowthKit setupSharedInstanceWithApplicationID:@"appid1"];
    [[GrowthKit sharedInstance]setUserData:userId firstName:@"Dan" lastName:@"Foo"];
    GRKInvitePageViewController *vc = [[GRKInvitePageViewController alloc] init];
    
    id mockHTTPManager = [OCMockObject partialMockForObject: [GrowthKit sharedInstance].HTTPManager];
    [[mockHTTPManager expect] sendInvitePageOpen:userId];
    
    [vc viewDidLoad];
    
    [mockHTTPManager verify];
}


@end
