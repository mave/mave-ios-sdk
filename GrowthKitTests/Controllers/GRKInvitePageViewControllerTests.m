//
//  GRKInvitePageViewControllerTests.m
//  GrowthKit
//
//  Created by dannycosson on 10/14/14.
//
//

#import <XCTest/XCTest.h>
#import "GrowthKit.h"
#import "GRKInvitePageViewController.h"
#import "GRKHTTPManager.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

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
    GRKHTTPManager *mockHTTPManager = mock([GRKHTTPManager class]);
    [GrowthKit sharedInstance].HTTPManager = mockHTTPManager;
    
    [vc sendInvites:nil];
    
    MKTArgumentCaptor *argument = [[MKTArgumentCaptor alloc] init];
    [verify(mockHTTPManager) sendInvitesWithPersons:invitePhones
                                            message:inviteMessage
                                       successBlock:[argument capture]];
//    GRKHTTPCompletionBlock completionBlock = [argument value];
}


@end
