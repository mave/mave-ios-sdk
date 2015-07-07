//
//  MAVEContactsInvitePageSearchManagerTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 7/1/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MAVEABTableViewController.h"
#import "MAVEContactsInvitePageSearchManager.h"

@interface MAVEContactsInvitePageSearchManagerTests : XCTestCase

@end

@implementation MAVEContactsInvitePageSearchManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    MAVEContactsInvitePageDataManager *dataManager = [[MAVEContactsInvitePageDataManager alloc] init];
    UITableView *mainTable = [[UITableView alloc] init];
    UITableView *searchTable = [[UITableView alloc] init];
    MAVEContactsInvitePageSearchManager *searchManager = [[MAVEContactsInvitePageSearchManager alloc] initWithDataManager:dataManager mainTable:mainTable andSearchTable:searchTable];
    XCTAssertNotNil(searchManager);
    XCTAssertEqualObjects(searchManager.dataManager, dataManager);
    XCTAssertEqualObjects(searchManager.mainTable, mainTable);
    XCTAssertEqualObjects(searchManager.searchTable, searchTable);
    XCTAssertNil(searchManager.useNewNumber);
    XCTAssertFalse(searchManager.didSendToNewNumber);
    XCTAssertNil(searchManager.useNewEmail);
    XCTAssertFalse(searchManager.didSendToNewEmail);
}

- (void)testSearchContactsAndUpdateTableNormalSearchTerm {
    MAVEContactsInvitePageDataManager *dataManager = [[MAVEContactsInvitePageDataManager alloc] init];
    dataManager.allContacts = @[@1,@2];
    UITableView *mainTable = [[UITableView alloc] init];
    id searchTableMock = OCMClassMock([UITableView class]);
    OCMExpect([searchTableMock reloadData]);
    MAVEContactsInvitePageSearchManager *searchManager = [[MAVEContactsInvitePageSearchManager alloc] initWithDataManager:dataManager mainTable:mainTable andSearchTable:searchTableMock];
    XCTAssertNotNil(searchManager);

    id abtvcMock = OCMClassMock([MAVEABTableViewController class]);
    NSArray *fakeSearchTableData = @[@1];
    OCMExpect([abtvcMock searchContacts:dataManager.allContacts withText:@"blah"]).andReturn(fakeSearchTableData);

    [searchManager searchContactsAndUpdateSearchTableWithTerm:@"blah"];

    XCTAssertEqualObjects(dataManager.searchTableData, fakeSearchTableData);
    OCMVerifyAll(abtvcMock);
    OCMVerifyAll(searchTableMock);
}

- (void)testSearchContactsAndUpdateTableAddNewPhoneNumber {
    // any search term that looks like a phone number doesn't get searched, we'll just show
    // the option to invite that new number
    MAVEContactsInvitePageDataManager *dataManager = [[MAVEContactsInvitePageDataManager alloc] init];
    dataManager.allContacts = @[];
    UITableView *mainTable = [[UITableView alloc] init];
    id searchTableMock = OCMClassMock([UITableView class]);
    OCMExpect([searchTableMock reloadData]);
    MAVEContactsInvitePageSearchManager *searchManager = [[MAVEContactsInvitePageSearchManager alloc] initWithDataManager:dataManager mainTable:mainTable andSearchTable:searchTableMock];
    XCTAssertNotNil(searchManager);
    NSString *number = @"8085554567";

    // should search before checking phone number, and only if search result is empty
    // check to see if it's a valid phone number
    id abtvcMock = OCMClassMock([MAVEABTableViewController class]);
    NSArray *fakeSearchTableData = @[];
    OCMExpect([abtvcMock searchContacts:dataManager.allContacts withText:number]).andReturn(fakeSearchTableData);

    [searchManager searchContactsAndUpdateSearchTableWithTerm:number];
    XCTAssertEqualObjects(searchManager.useNewNumber, @"+18085554567");
    XCTAssertEqual([dataManager.searchTableData count], 0);
    OCMVerifyAll(abtvcMock);
    OCMVerifyAll(searchTableMock);
}

- (void)testSearchContactsAndUpdateTableUsesSearchResultsInsteadOfNewPhoneIfBothExist {
    MAVEContactsInvitePageDataManager *dataManager = [[MAVEContactsInvitePageDataManager alloc] init];
    dataManager.allContacts = @[];
    UITableView *mainTable = [[UITableView alloc] init];
    id searchTableMock = OCMClassMock([UITableView class]);
    OCMExpect([searchTableMock reloadData]);
    MAVEContactsInvitePageSearchManager *searchManager = [[MAVEContactsInvitePageSearchManager alloc] initWithDataManager:dataManager mainTable:mainTable andSearchTable:searchTableMock];
    XCTAssertNotNil(searchManager);
    NSString *number = @"8085554567";

    // should search before checking phone number, and only if search result is empty
    // check to see if it's a valid phone number
    id abtvcMock = OCMClassMock([MAVEABTableViewController class]);
    NSArray *fakeSearchTableData = @[@1];
    OCMExpect([abtvcMock searchContacts:dataManager.allContacts withText:number]).andReturn(fakeSearchTableData);

    [searchManager searchContactsAndUpdateSearchTableWithTerm:number];
    XCTAssertNil(searchManager.useNewNumber);
    XCTAssertEqual([dataManager.searchTableData count], 1);
    XCTAssertEqualObjects([dataManager.searchTableData objectAtIndex:0], @1);
    OCMVerifyAll(abtvcMock);
    OCMVerifyAll(searchTableMock);
}

- (void)testSearchContactsAndUpdateTableSetsDidSendToNewFlagsToFalse {
    MAVEContactsInvitePageSearchManager *searchManager = [[MAVEContactsInvitePageSearchManager alloc] initWithDataManager:nil mainTable:nil andSearchTable:nil];
    XCTAssertNotNil(searchManager);
    searchManager.didSendToNewNumber = YES;
    searchManager.didSendToNewEmail = YES;
    [searchManager searchContactsAndUpdateSearchTableWithTerm:@"foo"];
    XCTAssertFalse(searchManager.didSendToNewNumber);
    XCTAssertFalse(searchManager.didSendToNewEmail);
}

@end
