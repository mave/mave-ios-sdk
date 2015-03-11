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
#import "MAVEInviteTableHeaderView.h"

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
        // we will have set either the old or new style completion handler based on being on ios 7 or 8
        if (shareSheetVC.completionHandler) {
            shareSheetVC.completionHandler(nil, YES);
        } else {
            shareSheetVC.completionWithItemsHandler(nil, YES, nil, nil);
        }
        return YES;
    }] animated:YES completion:nil]);
    OCMExpect([APIInterfaceMock trackInvitePageOpenForPageType:MAVEInvitePageTypeNativeShareSheet]);
    
    [ipvc presentShareSheet];
    
    OCMVerifyAll(VCMock);
    OCMVerifyAll(APIInterfaceMock);
}


- (void)testLayoutInviteExplanationBoxWhenCopyNotNil {
    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    [ipvc loadView]; [ipvc viewDidLoad];

    MAVEABTableViewController *abtvc = ipvc.ABTableViewController;

    CGFloat expectedWidth = ipvc.view.frame.size.width;
    CGFloat expectedHeight = round([abtvc.inviteTableHeaderView computeHeightWithWidth:expectedWidth]);
    XCTAssertGreaterThan(expectedWidth, 0);
    XCTAssertGreaterThan(expectedHeight, 0);

    // Next 3 assertions from JG"s search addition
    XCTAssertEqual(abtvc.inviteTableHeaderView.frame.size.width, expectedWidth);
    XCTAssertEqual(abtvc.inviteTableHeaderView.frame.size.height, expectedHeight);
    XCTAssertEqualObjects(abtvc.tableView.tableHeaderView,
                          abtvc.inviteTableHeaderView);

    // Top "bounce region" should look like it connects to the header and be at the top
    // of the table view tall as the whole screen
    XCTAssertEqualObjects(abtvc.aboveTableContentView.backgroundColor,
                          abtvc.inviteTableHeaderView.inviteExplanationView.backgroundColor);
    XCTAssertEqualObjects(abtvc.aboveTableContentView.superview,
                          abtvc.tableView);
    CGFloat fullAppHeight = ipvc.view.frame.size.height;
    CGRect expectedAboveViewFrame = CGRectMake(0, 0 - fullAppHeight, expectedWidth, fullAppHeight);
    CGRect aboveViewFrame = ipvc.ABTableViewController.aboveTableContentView.frame;
    XCTAssertTrue(CGRectEqualToRect(aboveViewFrame, expectedAboveViewFrame));
}

- (void)testLayoutInviteExplanationBoxIfCopyIsEmpty {
    id sdkMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([sdkMock inviteExplanationCopy]).andReturn(nil);

    MAVEInvitePageViewController *ipvc = [[MAVEInvitePageViewController alloc] init];
    [ipvc loadView]; [ipvc viewDidLoad];

    MAVEABTableViewController *abtvc = ipvc.ABTableViewController;
    
    XCTAssertEqual(abtvc.inviteTableHeaderView.frame.size.width, abtvc.tableView.frame.size.width);
    XCTAssertEqual(abtvc.inviteTableHeaderView.frame.size.height, MAVESearchBarHeight);
    XCTAssertNil(abtvc.inviteTableHeaderView.inviteExplanationView);
    OCMVerifyAll(sdkMock);
}

//
- (void)testRespondAsAdditionalTableViewDelegate {
    id mock = [OCMockObject mockForClass:[MAVEInviteMessageView class]];
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    vc.bottomActionContainerView.inviteMessageView = mock;
    OCMExpect([mock updateNumberPeopleSelected:2]);
    [vc ABTableViewControllerNumberSelectedChanged:2];
    OCMVerify(mock);
}

- (void)testDismissSelf {
    id chooserMock = OCMClassMock([MAVEInvitePageChooser class]);
    [MaveSDK sharedInstance].invitePageChooser = chooserMock;

    OCMExpect([chooserMock dismissOnSuccess:304]);

    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    [vc loadView]; [vc viewDidLoad];

    [vc dismissSelf:304];

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
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1; p1.firstName = @"Foo";
    NSArray *inviteContacts = @[p1];
    vc.ABTableViewController.selectedPhoneNumbers = [[NSMutableSet alloc] initWithArray: invitePhones];
    vc.ABTableViewController.selectedPeople = [[NSMutableSet alloc] initWithArray:inviteContacts];
    vc.bottomActionContainerView.inviteMessageView.textView.text = inviteMessage;

    // Create a mock http manager & stub the singleton object to use it
    id mockAPIInterface = [OCMockObject partialMockForObject:[MaveSDK sharedInstance].APIInterface];
    OCMExpect([mockAPIInterface sendInvitesWithRecipientPhoneNumbers:invitePhones
                                             recipientContactRecords:inviteContacts
                                                             message:inviteMessage
                                                              userId:mave.userData.userID
                                            inviteLinkDestinationURL:mave.userData.inviteLinkDestinationURL
                                                          customData:nil
                                                     completionBlock:[OCMArg any]]);
    [vc sendInvites];
    OCMVerifyAll(mockAPIInterface);
}

- (void)testComposeClientGroupInvites {
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    [vc loadView];
    [vc viewDidLoad];

    // Setup content for invites
    NSArray *invitePhones = @[@"18085551234"];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1; p1.firstName = @"Foo";
    NSArray *inviteContacts = @[p1];
    vc.ABTableViewController.selectedPhoneNumbers = [[NSMutableSet alloc] initWithArray: invitePhones];
    vc.ABTableViewController.selectedPeople = [[NSMutableSet alloc] initWithArray:inviteContacts];

    UIViewController *fakeMessageComposeVC = OCMClassMock([MFMessageComposeViewController class]);
    id maveSharerMock = OCMClassMock([MAVESharer class]);
    OCMExpect([maveSharerMock composeClientSMSInviteToRecipientPhones:invitePhones completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        void (^completionBlock)(MessageComposeResult result) = obj;
        completionBlock(MessageComposeResultSent);
        return YES;
    }]]).andReturn(fakeMessageComposeVC);

    id vcMock = OCMPartialMock(vc);
    OCMExpect([vcMock presentViewController:fakeMessageComposeVC animated:YES completion:nil]);

    [vc composeClientGroupSMSInvites];

    OCMVerifyAll(vcMock);
    OCMVerifyAll(maveSharerMock);
}

///
/// Tests for the load contacts invite view code
///
- (void)testLoadViewWhenContactsPermissionGranted {
    // Mock permissions checking and setup to return fake data
    id mockABUtils = OCMClassMock([MAVEABUtils class]);
    OCMStub([mockABUtils addressBookPermissionStatus]).andReturn(MAVEABPermissionStatusAllowed);
    id mockPrompter = OCMClassMock([MAVEABPermissionPromptHandler class]);
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init]; p1.recordID = 1;
    p1.firstName = @"Foo";
    NSArray *fakeContacts = @[p1];

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

- (void)testCreateAddressBookInviteViewWhenServerSideSMSMethod {
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    remoteConfig.contactsInvitePage.smsInviteSendMethod = MAVESMSInviteSendMethodServerSide;
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMStub([maveMock remoteConfiguration]).andReturn(remoteConfig);

    // run code under test
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    UIView *view = [vc createAddressBookInviteView];

    // test views are layed out as expected
    XCTAssertEqual(vc.bottomActionContainerView.smsInviteSendMethod, MAVESMSInviteSendMethodServerSide);
    XCTAssertTrue([vc.bottomActionContainerView.inviteMessageView isDescendantOfView:view]);
    XCTAssertFalse([vc.bottomActionContainerView.clientSideBottomActionView isDescendantOfView:view]);

    // test send button will call the right method
    UIButton *sendButton = vc.bottomActionContainerView.inviteMessageView.sendButton;
    XCTAssertEqual([sendButton.allTargets count], 1);
    id target = [sendButton.allTargets anyObject];
    NSArray *actions =[sendButton actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
    XCTAssertEqual([actions count], 1);
    NSString *action = [actions objectAtIndex:0];
    XCTAssertEqualObjects(action, @"sendInvites");
}

- (void)testCreateAddressBookInviteViewWhenClientSideGroupSMSMethod{
    MAVERemoteConfiguration *remoteConfig = [[MAVERemoteConfiguration alloc] initWithDictionary:[MAVERemoteConfiguration defaultJSONData]];
    remoteConfig.contactsInvitePage.smsInviteSendMethod = MAVESMSInviteSendMethodClientSideGroup;
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMStub([maveMock remoteConfiguration]).andReturn(remoteConfig);

    // run code under test
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    UIView *view = [vc createAddressBookInviteView];

    // test views are layed out as expected
    XCTAssertEqual(vc.bottomActionContainerView.smsInviteSendMethod, MAVESMSInviteSendMethodClientSideGroup);
    XCTAssertFalse([vc.bottomActionContainerView.inviteMessageView isDescendantOfView:view]);
    XCTAssertTrue([vc.bottomActionContainerView.clientSideBottomActionView isDescendantOfView:view]);

    // test send button will call the right method
    UIButton *sendButton = vc.bottomActionContainerView.clientSideBottomActionView.sendButton;
    XCTAssertEqual([sendButton.allTargets count], 1);
    id target = [sendButton.allTargets anyObject];
    NSArray *actions =[sendButton actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
    XCTAssertEqual([actions count], 1);
    NSString *action = [actions objectAtIndex:0];
    XCTAssertEqualObjects(action, @"composeClientGroupSMSInvites");
}

// Tests for the helper for displaying suggested invites
- (void)testBuildContactsToUseAtPageRenderWhenShowSuggestedFlaggedOff {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];

    // flag off the show suggested flag
    MAVERemoteConfiguration *config = [[MAVERemoteConfiguration alloc] init];
    config.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] init];
    config.contactsInvitePage.suggestedInvitesEnabled = NO;
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    id utilsMock = OCMClassMock([MAVEABUtils class]);
    OCMExpect([maveMock remoteConfiguration]).andReturn(config);
    NSArray *inputContacts = @[@"one", @"two"];
    NSDictionary *indexedContacts = @{@"A": @[@"foo", @"bar"], @"#": @[@"nums"]};
    OCMExpect([utilsMock indexABPersonArrayForTableSections:inputContacts]).andReturn(indexedContacts);

    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    NSDictionary *outputContacts = nil;
    BOOL outputAddSuggestedBool = NO;
    [vc buildContactsToUseAtPageRender:&outputContacts
            addSuggestedLaterWhenReady:&outputAddSuggestedBool
                      fromContactsList:inputContacts];

    // expect it to not change the input contacts and not need to fetch later
    XCTAssertEqualObjects(outputContacts, indexedContacts);
    XCTAssertFalse(outputAddSuggestedBool);
    OCMVerifyAll(maveMock);
    OCMVerifyAll(utilsMock);
}

- (void)testBuildContactsToUseAtPageRenderWhenFlaggedOnAndContactsAlreadyReturned {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];

    // flag on the show suggested flag
    MAVERemoteConfiguration *config = [[MAVERemoteConfiguration alloc] init];
    config.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] init];
    config.contactsInvitePage.suggestedInvitesEnabled = YES;
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock remoteConfiguration]).andReturn(config);

    // Set the suggested contacts as already fulfilled && mock the return val
    [MaveSDK sharedInstance].suggestedInvitesBuilder.promise.status = MAVEPromiseStatusFulfilled;
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Foobar";
    NSArray *fakeSuggested = @[p1];
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"Not Suggested";
    NSArray *inputContacts = @[p2];
    OCMExpect([maveMock suggestedInvitesWithFullContactsList:inputContacts delay:0]).andReturn(fakeSuggested);


    NSDictionary *expectedOutputContacts = @{@"★": @[p1], @"N": @[p2]};
    NSDictionary *outputContactsList = nil;
    BOOL outputAddSuggestedBool = NO;
    [vc buildContactsToUseAtPageRender:&outputContactsList
            addSuggestedLaterWhenReady:&outputAddSuggestedBool
                      fromContactsList:inputContacts];

    XCTAssertEqualObjects(outputContactsList, expectedOutputContacts);
    XCTAssertFalse(outputAddSuggestedBool);
    OCMVerifyAll(maveMock);
}

- (void)testBuildContactsToUseAtPageRenderWhenFlaggedOnAndContactsAlreadyReturnedEmpty {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];

    // flag on the show suggested flag
    MAVERemoteConfiguration *config = [[MAVERemoteConfiguration alloc] init];
    config.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] init];
    config.contactsInvitePage.suggestedInvitesEnabled = YES;
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock remoteConfiguration]).andReturn(config);

    // Set the suggested contacts as already fulfilled but empty.
    // In this state, we should not add the suggestions category to the table
    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"Not Suggested";
    NSArray *inputContacts = @[p2];
    [MaveSDK sharedInstance].suggestedInvitesBuilder.promise.status = MAVEPromiseStatusRejected;
    OCMExpect([maveMock suggestedInvitesWithFullContactsList:inputContacts delay:0]).andReturn(@[]);

    NSDictionary *expectedOutputContacts = @{@"N": @[p2]};
    NSDictionary *outputContactsList = nil;
    BOOL outputAddSuggestedBool = NO;
    [vc buildContactsToUseAtPageRender:&outputContactsList
            addSuggestedLaterWhenReady:&outputAddSuggestedBool
                      fromContactsList:inputContacts];

    XCTAssertEqualObjects(outputContactsList, expectedOutputContacts);
    XCTAssertFalse(outputAddSuggestedBool);
    OCMVerifyAll(maveMock);
}

- (void)testBuildContactsToUseAtPageRenderWhenFlaggedOnAndWaitingOnContactsToBeReturned {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"appid1"];

    // flag on the show suggested flag
    MAVERemoteConfiguration *config = [[MAVERemoteConfiguration alloc] init];
    config.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] init];
    config.contactsInvitePage.suggestedInvitesEnabled = YES;
    id maveMock = OCMPartialMock([MaveSDK sharedInstance]);
    OCMExpect([maveMock remoteConfiguration]).andReturn(config);

    // Set the suggested contacts as not yet fulfilled
    [MaveSDK sharedInstance].suggestedInvitesBuilder.promise.status = MAVEPromiseStatusUnfulfilled;
    [[[maveMock reject] ignoringNonObjectArgs] suggestedInvitesWithFullContactsList:[OCMArg any] delay:0];

    MAVEInvitePageViewController *vc = [[MAVEInvitePageViewController alloc] init];
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init]; p2.firstName = @"Not Suggested";
    NSArray *inputContacts = @[p2];
    // should return the pending empty suggestions section
    NSDictionary *expectedOutputContacts = @{@"★": @[], @"N": @[p2]};
    NSDictionary *outputContactsList = nil;
    BOOL outputAddSuggestedBool = NO;
    [vc buildContactsToUseAtPageRender:&outputContactsList
            addSuggestedLaterWhenReady:&outputAddSuggestedBool
                      fromContactsList:inputContacts];

    XCTAssertEqualObjects(outputContactsList, expectedOutputContacts);
    XCTAssertTrue(outputAddSuggestedBool);
    OCMVerifyAll(maveMock);
}

@end