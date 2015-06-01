//
//  MAVEContactIdentifiersSortingTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/27/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEContactPhoneNumber.h"
#import "MAVEContactEmail.h"

@interface MAVEContactIdentifiersSortingTests : XCTestCase

@end

@implementation MAVEContactIdentifiersSortingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testComparePhonesSameLabel {
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMain];
    MAVEContactPhoneNumber *phone2 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085559999" andLabel:MAVEContactPhoneLabelMain];
    XCTAssertEqual([phone1 compareContactIdentifiers:phone2], NSOrderedSame);
    XCTAssertEqual([phone2 compareContactIdentifiers:phone1], NSOrderedSame);
}

- (void)testComparePhonesiPhoneHigherThanMobile {
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabeliPhone];
    MAVEContactPhoneNumber *phone2 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085559999" andLabel:MAVEContactPhoneLabelMobile];
    // Cell is first
    XCTAssertEqual([phone1 compareContactIdentifiers:phone2], NSOrderedAscending);
    XCTAssertEqual([phone2 compareContactIdentifiers:phone1], NSOrderedDescending);
}

- (void)testComparePhonesMobileHigherThanMain {
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    MAVEContactPhoneNumber *phone2 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085559999" andLabel:MAVEContactPhoneLabelMain];
    // Cell is first
    XCTAssertEqual([phone1 compareContactIdentifiers:phone2], NSOrderedAscending);
    XCTAssertEqual([phone2 compareContactIdentifiers:phone1], NSOrderedDescending);
}

- (void)testComparePhonesMainHigherThanOther {
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMain];
    MAVEContactPhoneNumber *phone2 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085559999" andLabel:MAVEContactPhoneLabelOther];
    // Cell is first
    XCTAssertEqual([phone1 compareContactIdentifiers:phone2], NSOrderedAscending);
    XCTAssertEqual([phone2 compareContactIdentifiers:phone1], NSOrderedDescending);
}

- (void)testCompareEmailsGmailAboveOthers {
    // Two emails of same domain have no preference
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo@gmail.com"];
    MAVEContactEmail *email2 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    XCTAssertEqual([email1 compareContactIdentifiers:email2], NSOrderedAscending);
    XCTAssertEqual([email2 compareContactIdentifiers:email1], NSOrderedDescending);

}

- (void)testCompareEmailsSameDomain {
    // Two emails of same domain have no preference
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    MAVEContactEmail *email2 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    XCTAssertEqual([email1 compareContactIdentifiers:email2], NSOrderedSame);
    XCTAssertEqual([email2 compareContactIdentifiers:email1], NSOrderedSame);

    MAVEContactEmail *email3 = [[MAVEContactEmail alloc] initWithValue:@"foo@gmail.com"];
    MAVEContactEmail *email4 = [[MAVEContactEmail alloc] initWithValue:@"bar@gmail.com"];
    XCTAssertEqual([email3 compareContactIdentifiers:email4], NSOrderedSame);
    XCTAssertEqual([email4 compareContactIdentifiers:email3], NSOrderedSame);
}

- (void)testPhonesBeforeEmails {
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelOther];
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo@gmail.com"];
    XCTAssertEqual([phone1 compareContactIdentifiers:email1], NSOrderedAscending);
    XCTAssertEqual([email1 compareContactIdentifiers:phone1], NSOrderedDescending);
}

- (void)testSortAListOfPhonesAndEmails {
    // Two emails have no preference
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    MAVEContactEmail *email2 = [[MAVEContactEmail alloc] initWithValue:@"bar@example.com"];
    MAVEContactPhoneNumber *phone1 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMobile];
    MAVEContactPhoneNumber *phone2 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085551234" andLabel:MAVEContactPhoneLabelMain];
    MAVEContactPhoneNumber *phone3 = [[MAVEContactPhoneNumber alloc] initWithValue:@"+18085559999" andLabel:MAVEContactPhoneLabelOther];
    NSArray *list = @[phone3, email1, phone2, email2, phone1];
    // assume sort is stable so email 1 & 2 stay in the order they were given
    NSArray *expectedOrder = @[phone1, phone2, phone3, email1, email2];
    XCTAssertEqualObjects([list sortedArrayUsingSelector:@selector(compareContactIdentifiers:)], expectedOrder);
}


@end
