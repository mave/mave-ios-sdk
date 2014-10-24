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
#import "GRKDisplayOptionsFactory.h"
#import "GRKInviteMessageView.h"

@interface GRKInvitePageViewControllerTests : XCTestCase

@end

@implementation GRKInvitePageViewControllerTests

- (void)setUp {
    [super setUp];
    [GrowthKit resetSharedInstanceForTesting];
    [GrowthKit setupSharedInstanceWithApplicationID:@"1231234"];
    [GrowthKit sharedInstance].currentUserId = @"foo";
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
                                              userId:[GrowthKit sharedInstance].currentUserId
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

//
// Test any views that don't have own custom subclass with own tests
//
- (void)testNavigationBarSetup {
    [GrowthKit setupSharedInstanceWithApplicationID:@"appid1"];
    GRKDisplayOptions *opts = [GRKDisplayOptionsFactory generateDisplayOptions];
    [GrowthKit sharedInstance].displayOptions = opts;

    GRKInvitePageViewController *vc = [[GRKInvitePageViewController alloc] init];
    UINavigationController *sampleNavigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    XCTAssertNotNil(sampleNavigationController);
    [vc setupNavigationBar];
    XCTAssertEqualObjects(vc.navigationItem.title, @"Invite Friends");
    XCTAssertEqualObjects(vc.navigationController.navigationBar.barTintColor,
                          opts.navigationBarBackgroundColor);
}

@end