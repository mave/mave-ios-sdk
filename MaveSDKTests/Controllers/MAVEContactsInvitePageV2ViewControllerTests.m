//
//  MAVEContactsInvitePageV2ViewControllerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 4/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEDisplayOptionsFactory.h"
#import "MaveSDK.h"
#import "MAVEContactsInvitePageV2ViewController.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEContactsInvitePageV2ViewControllerTests : XCTestCase

@end

@implementation MAVEContactsInvitePageV2ViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetupAboveTableView {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    [vc loadView];

    XCTAssertEqualObjects(vc.wrapperView.aboveTableView.messageTextView, vc.messageTextView);
    XCTAssertEqualObjects(vc.wrapperView.aboveTableView.searchBar, vc.searchBar);
    XCTAssertEqualObjects(vc.messageTextView.delegate, vc);
    XCTAssertEqualObjects(vc.searchBar.delegate, vc);

    // Return key types
    XCTAssertEqual(vc.messageTextView.returnKeyType, UIReturnKeyDone);
    XCTAssertEqual(vc.searchBar.returnKeyType, UIReturnKeyDone);
}

- (void)testSetupTableView {
    MAVEDisplayOptions *opts = [MAVEDisplayOptionsFactory generateDisplayOptions];
    [MaveSDK sharedInstance].displayOptions = opts;

    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    [vc loadView];

    XCTAssertEqualObjects(vc.wrapperView.tableView, vc.tableView);
    XCTAssertEqualObjects(vc.wrapperView.searchTableView, vc.searchTableView);

    // data source/delegate items
    XCTAssertEqualObjects(vc.tableView.delegate, vc);
    XCTAssertEqualObjects(vc.tableView.dataSource, vc);
    XCTAssertEqualObjects(vc.searchTableView.delegate, vc);
    XCTAssertEqualObjects(vc.searchTableView.delegate, vc);

    XCTAssertEqual(vc.tableView.separatorStyle, UITableViewCellSeparatorStyleSingleLine);
    XCTAssertEqualObjects(vc.tableView.separatorColor, opts.contactSeparatorColor);
    XCTAssertEqualObjects(vc.tableView.sectionIndexColor, opts.contactSectionIndexColor);
    XCTAssertEqualObjects(vc.tableView.sectionIndexBackgroundColor,
                          opts.contactSectionIndexBackgroundColor);
    XCTAssertEqualObjects(vc.tableView.backgroundColor, opts.contactCellBackgroundColor);
}

- (void)testOtherSetup {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    [vc loadView];

    XCTAssertEqualObjects(vc.navigationItem.title, @"Send Separately");
}

- (void)testKeyboardWillChangeFrameNotification {
    // it should set the search table content inset when keyboard shwos up
    NSValue *frameVal = [NSValue valueWithCGRect:CGRectMake(0, 200, 100, 31)];
    NSNotification *notif = [[NSNotification alloc] initWithName:@"foo" object:nil userInfo:@{UIKeyboardFrameEndUserInfoKey: frameVal}];

    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    [vc loadView];
    XCTAssertEqual(vc.searchTableView.contentInset.bottom, 0);

    [vc keyboardWillChangeFrameNotification:notif];

    XCTAssertEqual(vc.currentKeyboardHeightFromBottom, 31);
    XCTAssertEqual(vc.searchTableView.contentInset.bottom, 31);
}

- (void)testHeightForRowAtIndexPath {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];

    CGFloat height = [vc tableView:nil heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    // check value returned is non-zero and reasonable, no need to
    // hard-code exact value
    XCTAssertGreaterThan(height, 30);
}

- (void)testUpdateTableDataAndCountSectionsAndRows {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Ben";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"Bat";
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.firstName = @"Aaron";
    NSDictionary *data = @{@"B": @[p1, p2], @"A": @[p3]};
    XCTAssertEqual([vc numberOfSectionsInTableView:vc.tableView], 0);

    [vc updateTableData:data];

    XCTAssertEqualObjects(vc.tableData, data);
    NSArray *expectedSections = @[@"A", @"B"];
    XCTAssertEqualObjects(vc.tableSections, expectedSections);
    NSArray *expectedAllContacts = @[p3, p1, p2];
    XCTAssertEqualObjects(vc.allContacts, expectedAllContacts);

    XCTAssertEqual([vc numberOfSectionsInTableView:vc.tableView], 2);
    XCTAssertEqual([vc tableView:vc.tableView numberOfRowsInSection:0], 1);
    XCTAssertEqual([vc tableView:vc.tableView numberOfRowsInSection:1], 2);
}

- (void)testUpdateTableDataWithSuggestedInvitesWhenSuggestions {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    [vc loadView];
    vc.tableData = @{MAVESuggestedInvitesTableDataKey: @[], @"A": @[]};
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Blah";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"Cah";
    NSArray *suggestions = @[p1, p2];
    NSDictionary *expectedData = @{MAVESuggestedInvitesTableDataKey:suggestions,
                                   @"A": @[]};
    NSArray *indexesOfSuggestions = @[
        [NSIndexPath indexPathForRow:0 inSection:0],
        [NSIndexPath indexPathForRow:1 inSection:0],
    ];

    id tableViewMock = OCMPartialMock(vc.tableView);
    id mock = OCMPartialMock(vc);
    OCMExpect([mock updateTableDataWithoutReloading:expectedData]);

    OCMExpect([tableViewMock beginUpdates]);
    OCMExpect([tableViewMock insertRowsAtIndexPaths:indexesOfSuggestions withRowAnimation:UITableViewRowAnimationTop]);
    OCMExpect([tableViewMock endUpdates]);

    [vc updateTableDataAnimatedWithSuggestedInvites:suggestions];

    OCMVerifyAll(mock);
    OCMVerifyAll(tableViewMock);
}

- (void)testUpdateTableDataWithSuggestionsWhenNoSuggestions {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    vc.tableData = @{MAVESuggestedInvitesTableDataKey: @[], @"A": @[]};
    NSDictionary *expectedData = @{@"A": @[]};

    id mock = OCMPartialMock(vc);
    OCMExpect([mock updateTableData:expectedData]);

    [vc updateTableDataAnimatedWithSuggestedInvites:@[]];

    OCMVerifyAll(mock);
}

- (void)testEnumerateAllContacts {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.firstName = @"Ben";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p1.recordID = 2; p2.firstName = @"Bat";
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.recordID = 3; p3.firstName = @"Aaron";
    [vc updateTableData: @{MAVESuggestedInvitesTableDataKey:@[p2],
                     @"A": @[p3],
                     @"B": @[p1, p2],
    }];

    NSArray *allContacts = @[p2, p3, p1];
    XCTAssertEqualObjects([vc enumerateAllContacts], allContacts);
}

- (void)testPersonAtIndexPath {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.firstName = @"Ben";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p2.firstName = @"Bat";
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.firstName = @"Aaron";
    NSDictionary *data = @{@"B": @[p1, p2], @"A": @[p3]};
    [vc updateTableData:data];

    MAVEABPerson *received1 = [vc tableView:vc.tableView personForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    MAVEABPerson *received2 = [vc tableView:vc.tableView personForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    MAVEABPerson *received3 = [vc tableView:vc.tableView personForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    XCTAssertEqualObjects(received1, p1);
    XCTAssertEqualObjects(received2, p2);
    XCTAssertEqualObjects(received3, p3);
}

- (void)testUpdatePersonToIndexPathsIndex {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    p1.recordID = 1; p1.firstName = @"Ben";
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    p1.recordID = 2; p2.firstName = @"Bat";
    MAVEABPerson *p3 = [[MAVEABPerson alloc] init];
    p3.recordID = 3; p3.firstName = @"Aaron";
    vc.tableData = @{MAVESuggestedInvitesTableDataKey:@[p2],
                     @"A": @[p3],
                     @"B": @[p1, p2],
                     };
    NSArray *p1IPs = @[[NSIndexPath indexPathForRow:0 inSection:2]];
    NSArray *p2IPs = @[[NSIndexPath indexPathForRow:0 inSection:0],
                       [NSIndexPath indexPathForRow:1 inSection:2],
                       ];
    NSArray *p3IPs = @[[NSIndexPath indexPathForRow:0 inSection:1]];

    vc.tableSections = @[MAVESuggestedInvitesTableDataKey, @"A", @"B"];

    [vc updatePersonToIndexPathsIndex];
    NSDictionary *index = vc.personToIndexPathsIndex;

    XCTAssertEqualObjects([index objectForKey:@(p1.recordID)], p1IPs);
    XCTAssertEqualObjects([index objectForKey:@(p2.recordID)], p2IPs);
    XCTAssertEqualObjects([index objectForKey:@(p3.recordID)], p3IPs);
}

- (void)testSendInviteToPersonSuccess {
  MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    [vc loadView];

    NSString *expectedMessage =  @"Foo text";
    vc.messageTextView.text = expectedMessage;
    NSArray *expectedPhones = @[@"+18085556789"];

    MAVEUserData *pSend = [[MAVEUserData alloc] init];
    pSend.userID = @"1";
    pSend.firstName = @"Dan"; pSend.lastName = @"Food";
    [[MaveSDK sharedInstance] identifyUser:pSend];

    MAVEABPerson *pRec = [[MAVEABPerson alloc] init];
    pRec.firstName = @"Recipient"; pRec.lastName = @"Person";
    pRec.phoneNumbers = expectedPhones;
    NSArray *expectedPeople = @[pRec];

    id vcMock = OCMPartialMock(vc);
    OCMExpect([vcMock inviteSentSuccessHandlerPerson:[OCMArg any] waitSema:[OCMArg any]]);
    id apiInterfaceMock = OCMPartialMock([MaveSDK sharedInstance].APIInterface);
    id tableViewMock = OCMPartialMock(vc.tableView);
    OCMExpect([tableViewMock reloadData]);
    id searchTableViewMock = OCMPartialMock(vc.searchTableView);
    OCMExpect([searchTableViewMock reloadData]);

    // expect calling out to the api, and call the completion block with no errors
    __block MAVEInviteSendingStatus sendingStatus;
    OCMExpect([apiInterfaceMock sendInvitesWithRecipientPhoneNumbers:expectedPhones
                                             recipientContactRecords:expectedPeople
                                                             message:expectedMessage
                                                              userId:pSend.userID
                                            inviteLinkDestinationURL:[OCMArg any]
                                                      wrapInviteLink:NO
                                                          customData:[OCMArg any]
                                                     completionBlock:[OCMArg checkWithBlock:^BOOL(id obj) {
        sendingStatus = pRec.sendingStatus;
        void(^completionBlock)(NSError *error, NSDictionary *responseData) = obj;
        completionBlock(nil, nil);
        return YES;
    }]]);

    [vc sendInviteToPerson:pRec selectedFromSuggestions:NO];

    OCMVerifyAll(vcMock);
    OCMVerifyAll(apiInterfaceMock);
    OCMVerifyAll(tableViewMock);
    OCMVerifyAll(searchTableViewMock);
    XCTAssertEqual(sendingStatus, MAVEInviteSendingStatusSending);
    XCTAssertFalse(pRec.selectedFromSuggestions);
}

- (void)testSendInviteToPersonWhenSelectedFromSuggestions {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    [vc loadView];
    MAVEABPerson *p = [[MAVEABPerson alloc] init];
    p.phoneNumbers = @[@"+18085556789"];
    XCTAssertFalse(p.selectedFromSuggestions);

    [vc sendInviteToPerson:p selectedFromSuggestions:YES];

    XCTAssertTrue(p.selectedFromSuggestions);
}

- (void)testinviteSentSuccessHandler {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    [vc loadView];
    id vcMock = OCMPartialMock(vc);
    MAVEABPerson *pRec = [[MAVEABPerson alloc] init];

    // search table is active, so we jump to the main table
    vc.searchTableView.hidden = NO;
    vc.tableView.hidden = YES;
    OCMExpect([vcMock jumpToMainTableRowForPerson:pRec]);

    id tableViewMock = OCMPartialMock(vc.tableView);
    OCMExpect([tableViewMock reloadData]);

    [vc innerInviteSentSuccessHandlerPerson:pRec];

    XCTAssertEqual(pRec.sendingStatus, MAVEInviteSendingStatusSent);
    OCMVerifyAll(vcMock);
    OCMVerifyAll(tableViewMock);
}

- (void)testInviteSentSuccessHandlerChangeNavBarItemToDone {
    MAVEContactsInvitePageV2ViewController *vc = [[MAVEContactsInvitePageV2ViewController alloc] init];
    [vc loadView];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    XCTAssertNotNil(navVC);
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
    vc.navigationItem.leftBarButtonItem.title = @"Cancel";

    [vc innerInviteSentSuccessHandlerPerson:nil];
    XCTAssertEqualObjects(vc.navigationItem.leftBarButtonItem.title, @"Done");
}

@end
