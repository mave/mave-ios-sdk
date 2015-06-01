//
//  MAVEContactsInvitePageV3ViewControllerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/28/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEContactsInvitePageV3ViewController.h"
#import "MAVEABPerson.h"
#import "MAVEContactPhoneNumber.h"
#import "MAVEContactEmail.h"
#import "MAVEBigSendButton.h"
#import "MAVEContactsInvitePageV3TableWrapperView.h"

@interface MAVEContactsInvitePageV3ViewControllerTests : XCTestCase

@end

@implementation MAVEContactsInvitePageV3ViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTogglePersonSelected {
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];
    MAVEContactsInvitePageV3TableWrapperView *wrapperView = [[MAVEContactsInvitePageV3TableWrapperView alloc] init];
    controller.wrapperView = wrapperView;

    XCTAssertEqual([controller.selectedPeopleIndex count], 0);
    XCTAssertEqual([controller.selectedContactIdentifiersIndex count], 0);

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    phone1.selected = YES;
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo1@example.com"];
    email1.selected = NO;
    MAVEContactEmail *email2 = [[MAVEContactEmail alloc] initWithValue:@"foo2@example.com"];
    email2.selected = YES;
    p1.phoneObjects = @[phone1];
    p1.emailObjects = @[email1, email2];

    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    MAVEContactEmail *email3 = [[MAVEContactEmail alloc] initWithValue:@"foo3@example.com"];
    email3.selected = YES;
    p2.emailObjects = @[email3];


    // Add people & check state is as expected
    id sendButtonMock = OCMPartialMock(wrapperView.bigSendButton);
    p1.selected = YES;
    [controller updateToReflectPersonSelectedStatus:p1];
    XCTAssertEqual([controller.selectedPeopleIndex count], 1);
    XCTAssertEqual([controller.selectedContactIdentifiersIndex count], 2);
    XCTAssertTrue([controller.selectedPeopleIndex containsObject:p1]);
    XCTAssertFalse([controller.selectedPeopleIndex containsObject:p2]);
    OCMVerify([sendButtonMock updateButtonTextNumberToSend:2]);
    [sendButtonMock stopMocking];
    sendButtonMock = OCMClassMock([MAVEBigSendButton class]);
    controller.wrapperView.bigSendButton = sendButtonMock;
    p2.selected = YES;
    [controller updateToReflectPersonSelectedStatus:p2];
    XCTAssertEqual([controller.selectedPeopleIndex count], 2);
    XCTAssertEqual([controller.selectedContactIdentifiersIndex count], 3);
    XCTAssertTrue([controller.selectedPeopleIndex containsObject:p1]);
    XCTAssertTrue([controller.selectedPeopleIndex containsObject:p2]);
    OCMVerify([sendButtonMock updateButtonTextNumberToSend:3]);
    [sendButtonMock stopMocking];
    // then remove them
    sendButtonMock = OCMClassMock([MAVEBigSendButton class]);
    controller.wrapperView.bigSendButton = sendButtonMock;
    p1.selected = NO;
    [controller updateToReflectPersonSelectedStatus:p1];
    XCTAssertEqual([controller.selectedPeopleIndex count], 1);
    XCTAssertEqual([controller.selectedContactIdentifiersIndex count], 1);
    XCTAssertFalse([controller.selectedPeopleIndex containsObject:p1]);
    XCTAssertTrue([controller.selectedPeopleIndex containsObject:p2]);
    XCTAssertTrue([controller.selectedPeopleIndex containsObject:p2]);
    OCMVerify([sendButtonMock updateButtonTextNumberToSend:1]);
    [sendButtonMock stopMocking];
    sendButtonMock = OCMClassMock([MAVEBigSendButton class]);
    controller.wrapperView.bigSendButton = sendButtonMock;
    p2.selected = NO;
    [controller updateToReflectPersonSelectedStatus:p2];
    XCTAssertEqual([controller.selectedPeopleIndex count], 0);
    XCTAssertEqual([controller.selectedContactIdentifiersIndex count], 0);
    XCTAssertFalse([controller.selectedPeopleIndex containsObject:p1]);
    XCTAssertFalse([controller.selectedPeopleIndex containsObject:p2]);
    OCMVerify([sendButtonMock updateButtonTextNumberToSend:0]);
}

- (void)testTogglePersonContactIdentifiersRemainUniqueWhenTwoPeopleHaveSameInfo {
    // There's no hash and equality methods for contact identifiers, so two objects initialized at different times even with
    // the same value are two separate objects, which is what we want for this collection.
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    p1.phoneObjects = @[phone1];
    MAVEABPerson *p2 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone2 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    p2.phoneObjects = @[phone2];

    p1.selected = YES;
    [controller updateToReflectPersonSelectedStatus:p1];
    XCTAssertEqual([controller.selectedPeopleIndex count], 1);
    XCTAssertEqual([controller.selectedContactIdentifiersIndex count], 1);

    p2.selected = YES;
    [controller updateToReflectPersonSelectedStatus:p2];
    XCTAssertEqual([controller.selectedPeopleIndex count], 2);
    XCTAssertEqual([controller.selectedContactIdentifiersIndex count], 2);
}

- (void)testSelectAllEmailsThenDeselect {
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];

    // we should favor gmail over unkown domains as a simple proxy for personal email
    // vs work or school email address
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init];
    MAVEContactEmail *email00 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    MAVEContactEmail *email01 = [[MAVEContactEmail alloc] initWithValue:@"bar@gmail.com"];
    p0.emailObjects = @[email00, email01];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    p1.phoneObjects = @[phone1];
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p1.emailObjects = @[email1];

    [controller.dataManager updateWithContacts:@[p0, p1] ifNecessaryAsyncSuggestionsBlock:nil];

    [controller selectOrDeselectAllEmails:YES];
    XCTAssertFalse(email00.selected);
    XCTAssertTrue(email01.selected);
    XCTAssertFalse(phone1.selected);
    XCTAssertTrue(email1.selected);

    [controller selectOrDeselectAllEmails:NO];
    XCTAssertFalse(email00.selected);
    XCTAssertFalse(email01.selected);
    XCTAssertFalse(phone1.selected);
    XCTAssertFalse(email1.selected);
}

- (void)testSelectAllEmailsWhenSomeRecordsAlreadySelected {
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];

    // we should favor gmail over unkown domains as a simple proxy for personal email
    // vs work or school email address
    MAVEABPerson *p0 = [[MAVEABPerson alloc] init];
    MAVEContactEmail *email00 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    email00.selected = YES;
    MAVEContactEmail *email01 = [[MAVEContactEmail alloc] initWithValue:@"bar@gmail.com"];
    p0.emailObjects = @[email00, email01];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    phone1.selected = YES;
    p1.phoneObjects = @[phone1];
    MAVEContactEmail *email10 = [[MAVEContactEmail alloc] initWithValue:@"foo@gmail.com"];
    MAVEContactEmail *email11 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p1.emailObjects = @[email10, email11];

    [controller.dataManager updateWithContacts:@[p0, p1] ifNecessaryAsyncSuggestionsBlock:nil];

    [controller selectOrDeselectAllEmails:YES];
    // if a non-top ranked email was already selected, leave it selected and dont
    // select the top ranked email we would have selected
    XCTAssertTrue(email00.selected);
    XCTAssertFalse(email01.selected);
    // if a phone was already selected, leave it selected but still select the email
    XCTAssertTrue(phone1.selected);
    XCTAssertTrue(email10.selected);
    XCTAssertFalse(email11.selected);

    [controller selectOrDeselectAllEmails:NO];
    XCTAssertFalse(email00.selected);
    XCTAssertFalse(email01.selected);
    XCTAssertTrue(phone1.selected);
    XCTAssertFalse(email10.selected);
    XCTAssertFalse(email00.selected);
}

- (void)testTogglePersonOnThenOffThenSelectAllEmailsOnlyHasEmailSelected {
    // Regression test for a bug when first building the page
    MAVEContactsInvitePageV3ViewController *controller = [[MAVEContactsInvitePageV3ViewController alloc] init];
    [controller viewDidLoad];

    MAVEABPerson *p1 = [[MAVEABPerson alloc] init];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    p1.phoneObjects = @[phone1];
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    p1.emailObjects = @[email1];

    [controller.dataManager updateWithContacts:@[p1] ifNecessaryAsyncSuggestionsBlock:nil];
    p1.selected = YES;
    [controller updateToReflectPersonSelectedStatus:p1];
    p1.selected = NO;
    [controller updateToReflectPersonSelectedStatus:p1];

    [controller selectOrDeselectAllEmails:YES];

    XCTAssertFalse(phone1.selected);
    XCTAssertTrue(email1.selected);
}

@end
