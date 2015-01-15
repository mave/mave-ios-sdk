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
#import "MAVEABUtils.h"
#import "MAVENoAddressBookPermissionView.h"
#import "MAVEABPermissionPromptHandler.h"
#import "MAVEInvitePageViewController.h"
#import "MAVEDisplayOptionsFactory.h"
#import "MAVEInviteMessageView.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

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
    [MaveSDK sharedInstance].defaultSMSMessageText = @"dfeault text";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPresentShareSheet {
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    id VCMock = OCMPartialMock(ipvc);
    id APIInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    
    OCMExpect([VCMock dismissSelf:1]);
    
    OCMExpect([VCMock presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
        UIActivityViewController *shareSheetVC = obj;
        XCTAssertNotNil(shareSheetVC);
        shareSheetVC.completionHandler(nil, YES);
        return YES;
    }] animated:YES completion:nil]);
    OCMExpect([APIInterfaceMock trackInvitePageOpenForPageType:MAVEInvitePageTypeNativeShareSheet]);
    
    [ipvc presentShareSheet];
    
    OCMVerifyAll(VCMock);
    OCMVerifyAll(APIInterfaceMock);
}


- (void)testDoLayoutInviteExplanationBoxIfCopyNotNil {
    MAVEInvitePageViewController *ipvc =
        [[MAVEInvitePageViewController alloc] init];
    [ipvc loadView]; [ipvc viewDidLoad];

    CGFloat expectedWidth = ipvc.view.frame.size.width;
    CGFloat expectedHeight = round([ipvc.inviteExplanationView computeHeightWithWidth:expectedWidth]);
    XCTAssertGreaterThan(expectedWidth, 0);
    XCTAssertGreaterThan(expectedHeight, 0);

    XCTAssertEqual(ipvc.inviteExplanationView.frame.size.width, expectedWidth);
    // TODO: look into why this test is flaky
//    XCTAssertEqual(ipvc.inviteExplanationView.frame.size.height, expectedHeight);
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
    __block NSUInteger numSent = 0;
    [MaveSDK sharedInstance].invitePageDismissBlock =
        ^void(UIViewController *viewController,
              NSUInteger numberOfInvitesSent) {
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
    MAVEInvitePageViewController *vc =
        [[MAVEInvitePageViewController alloc] init];

    id mockVC =  OCMPartialMock(vc);
    OCMExpect([mockVC dismissSelf:0]);
    [vc dismissAfterCancel];
    OCMVerifyAll(mockVC);
}

- (void)testViewDidLoadSetsUpNavigationBar {
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    [[MaveSDK sharedInstance].invitePageChooser embedInNavigationController:vc];

    id mock = OCMPartialMock(vc);
    OCMExpect([mock setupNavigationBar]);

    [vc viewDidLoad];

    OCMVerifyAll(mock);
}

- (void)testSetupNavigationBar {
    id chooserMock = OCMPartialMock([MaveSDK sharedInstance].invitePageChooser);

    // setup view controller
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    [[MaveSDK sharedInstance].invitePageChooser embedInNavigationController:vc];

    // sets up look and display of bar
    OCMExpect([chooserMock setupNavigationBar:vc
                          leftBarButtonTarget:vc
                          leftBarButtonAction:@selector(dismissAfterCancel)]);

    [vc setupNavigationBar];

    OCMVerifyAll(chooserMock);
}

//
// Sending requests
//
- (void)testSendInvites {
    MaveSDK *mave = [MaveSDK sharedInstance];
    mave.userData.inviteLinkDestinationURL = @"http://example.com/foo?referralCode=blah";
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    [vc loadView];
    [vc viewDidLoad];
    
    // Setup content for invites
    NSString *inviteMessage = @"This was the text typed in";
    NSArray *invitePhones = @[@"18085551234"];
    vc.ABTableViewController.selectedPhoneNumbers = [[NSMutableSet alloc] initWithArray: invitePhones];
    vc.inviteMessageContainerView.inviteMessageView.textView.text = inviteMessage;

    // Create a mock http manager & stub the singleton object to use it
    id mockAPIInterface = [OCMockObject partialMockForObject:[MaveSDK sharedInstance].APIInterface];

    [[mockAPIInterface expect] sendInvitesWithPersons:invitePhones
                                            message:inviteMessage
                                              userId:mave.userData.userID
                            inviteLinkDestinationURL:mave.userData.inviteLinkDestinationURL
                                     completionBlock:[OCMArg any]];
    [vc sendInvites];
    [mockAPIInterface verify];
}

///
/// Tests for the load contacts invite view code
///
- (void)testLoadViewWhenContactsPermissionGranted {
    // Mock permissions checking and setup to return fake data
    NSDictionary *fakeContacts = @{@"A": @"string"};
    id mockABUtils = OCMClassMock([MAVEABUtils class]);
    OCMStub([mockABUtils addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusAllowed);
    id mockPrompter = OCMClassMock([MAVEABPermissionPromptHandler class]);
    OCMExpect([mockPrompter promptForContactsWithCompletionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        MAVEABDataBlock completionBlock = obj;
        completionBlock(fakeContacts);
        return YES;
    }]]);

    // setup code and add test expectations
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];

    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    id mockVC = OCMPartialMock(vc);
    id fakeView = [[UIView alloc] init];
    OCMExpect([mockVC createAddressBookInviteView]).andReturn(fakeView);
    
    [vc loadView];

    OCMVerifyAll(mockVC);
    XCTAssertEqualObjects(vc.view, fakeView);
    OCMVerifyAll(mockPrompter);
    [mockABUtils stopMocking];
    [mockPrompter stopMocking];
}

- (void)testLoadViewWhenContactsPermissionUnprompted {
    // Mock permissions checking and setup to return fake data
    id mockABUtils = OCMClassMock([MAVEABUtils class]);
    OCMStub([mockABUtils addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusUnprompted);
    // do not call the block this time, we've already tested what it will do
    id mockPrompter = OCMClassMock([MAVEABPermissionPromptHandler class]);
    OCMExpect([mockPrompter promptForContactsWithCompletionBlock:[OCMArg any]]);

    // setup code and add test expectations
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];

    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    id mockVC = OCMPartialMock(vc);
    id fakeView = [[UIView alloc] init];
    OCMExpect([mockVC createAddressBookInviteView]).andReturn(fakeView);

    [vc loadView];

    OCMVerifyAll(mockVC);
    XCTAssertEqualObjects(vc.view, fakeView);
    OCMVerifyAll(mockPrompter);
    [mockABUtils stopMocking];
    [mockPrompter stopMocking];
}
@end