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
    [MaveSDK sharedInstance].displayOptions =
        [MAVEDisplayOptionsFactory generateDisplayOptions];
}

- (void)tearDown {
    [super tearDown];
}


- (void)testDoLayoutInviteExplanationBoxIfCopyNotNil {
    MAVEInvitePageViewController *ipvc =
        [[MAVEInvitePageViewController alloc] init];
    [ipvc loadView]; [ipvc viewDidLoad];

    CGFloat expectedWidth = ipvc.view.frame.size.width;
    CGFloat expectedHeight = [ipvc.inviteExplanationView computeHeightWithWidth:expectedWidth];
    XCTAssertGreaterThan(expectedWidth, 0);
    XCTAssertGreaterThan(expectedHeight, 0);

    XCTAssertEqual(ipvc.inviteExplanationView.frame.size.width, expectedWidth);
    XCTAssertEqual(ipvc.inviteExplanationView.frame.size.height, expectedHeight);
    XCTAssertEqualObjects(ipvc.ABTableViewController.tableView.tableHeaderView,
                          ipvc.inviteExplanationView);

    // Top "bounce region" should look like it connects to the header and be at the top
    // of the table view tall as the whole screen
    XCTAssertEqualObjects(ipvc.ABTableViewController.aboveTableContentView.backgroundColor,
                          ipvc.inviteExplanationView.backgroundColor);
    XCTAssertEqualObjects(ipvc.ABTableViewController.aboveTableContentView.superview,
                          ipvc.ABTableViewController.tableView);
    CGFloat fullAppHeight = ipvc.view.frame.size.height;
    CGRect expectedAboveViewFrame = CGRectMake(0, 0 - fullAppHeight, expectedWidth, fullAppHeight);
    CGRect aboveViewFrame = ipvc.ABTableViewController.aboveTableContentView.frame;
    XCTAssertTrue(CGRectEqualToRect(aboveViewFrame, expectedAboveViewFrame));
}

- (void)testDoNotLayoutInviteExplanationBoxIfCopyIsEmpty {
    [MaveSDK sharedInstance].displayOptions.inviteExplanationCopy = nil;

    MAVEInvitePageViewController *ipvc =
    [[MAVEInvitePageViewController alloc] init];
    [ipvc loadView]; [ipvc viewDidLoad];
    
    XCTAssertEqual(ipvc.inviteExplanationView.frame.size.width, 0);
    XCTAssertEqual(ipvc.inviteExplanationView.frame.size.height, 0);
    XCTAssertNil(ipvc.ABTableViewController.tableView.tableHeaderView);
}

//
- (void)testRespondAsAdditionalTableViewDelegate {
    id mock = [OCMockObject mockForClass:[MAVEInviteMessageView class]];
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    vc.inviteMessageContainerView.inviteMessageView = mock;
    OCMExpect([mock updateNumberPeopleSelected:2]);
    [vc ABTableViewControllerNumberSelectedChanged:2];
    OCMVerify(mock);
}

- (void)testAppropriateTeardownOnDismissSelf {
    __block unsigned int numSent = 0;
    [MaveSDK sharedInstance].invitePageDismissalBlock =
        ^void(UIViewController *viewController,
              unsigned int numberOfInvitesSent) {
        numSent = numberOfInvitesSent;
    };
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    [vc loadView]; [vc viewDidLoad];
    id vcViewMock = [OCMockObject partialMockForObject:vc.view];
    [[vcViewMock expect] endEditing:YES];

    [vc dismissSelf:3];

    XCTAssertEqual(numSent, 3);
    [vcViewMock verify];
}

- (void)testDismissAfterCancelCallsDismissSelf {
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    [vc loadView];
    [vc viewDidLoad];

    // Check that the cancel button is setup correctly
    UINavigationController *navVC = (UINavigationController *)vc;
    XCTAssertEqual(navVC.navigationItem.leftBarButtonItem.target, navVC);
    XCTAssertEqual(navVC.navigationItem.leftBarButtonItem.action, @selector(dismissAfterCancel));

    id mockVC = [OCMockObject partialMockForObject:vc];
    [[mockVC expect] dismissSelf:0];
    [vc dismissAfterCancel];
    [mockVC verify];
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
    vc.inviteMessageContainerView.inviteMessageView.textView.text = inviteMessage;

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