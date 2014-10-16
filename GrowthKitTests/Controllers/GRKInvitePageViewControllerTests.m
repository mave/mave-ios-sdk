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
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSendInvites {
    GRKInvitePageViewController *vc = [[GRKInvitePageViewController alloc] init];
    [vc createContainerAndChildViews];
    
    // Setup content for invites
    NSString *inviteMessage = @"This was the text typed in";
    NSArray *invitePhones = @[@"18085551234"];
    vc.ABTableViewController.selectedPhoneNumbers = [[NSMutableSet alloc] initWithArray: invitePhones];
    vc.inviteMessageViewController.view.textField.text = inviteMessage;

    // Create a mock http manager & stub the singleton object to use it
    id mockHTTPManager = [OCMockObject partialMockForObject:[GrowthKit sharedInstance].HTTPManager];

    [[mockHTTPManager expect] sendInvitesWithPersons:invitePhones
                                            message:inviteMessage
                                       completionBlock:[OCMArg any]];
    [vc sendInvites:nil];

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
