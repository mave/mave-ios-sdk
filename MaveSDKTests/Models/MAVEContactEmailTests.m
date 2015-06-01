//
//  MAVEContactEmailTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 5/27/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVEContactEmail.h"

@interface MAVEContactEmailTests : XCTestCase

@end

@implementation MAVEContactEmailTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitAndCheckHumanReadableConversions {
    MAVEContactEmail *email = [[MAVEContactEmail alloc] initWithValue:@"foo@bar.com"];
    XCTAssertFalse(email.selected);
    XCTAssertEqualObjects(email.value, @"foo@bar.com");
    XCTAssertEqualObjects(email.typeName, @"email");
    XCTAssertEqualObjects([email humanReadableValue], @"foo@bar.com");
    XCTAssertEqualObjects([email humanReadableValueForDetailedDisplay], @"foo@bar.com");
}

- (void)testDomain {
    // Our parsing shouldn't be picky about what's a real email,
    // just split at @ and take the second item in the array.
    // Return nil if bad format
    MAVEContactEmail *email0 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.io"];
    MAVEContactEmail *email2 = [[MAVEContactEmail alloc] initWithValue:@"foo+123@gmail.com"];
    MAVEContactEmail *email3 = [[MAVEContactEmail alloc] initWithValue:@"foo@example"];
    MAVEContactEmail *email4 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com@me.com@"];
    MAVEContactEmail *email5 = [[MAVEContactEmail alloc] initWithValue:@"foo@"];
    MAVEContactEmail *email6 = [[MAVEContactEmail alloc] initWithValue:@"foo"];
    MAVEContactEmail *email7 = nil;

    XCTAssertEqualObjects([email0 domain], @"example.com");
    XCTAssertEqualObjects([email1 domain], @"example.io");
    XCTAssertEqualObjects([email2 domain], @"gmail.com");
    XCTAssertEqualObjects([email3 domain], @"example");
    XCTAssertEqualObjects([email4 domain], @"example.com");
    XCTAssertEqualObjects([email5 domain], nil);
    XCTAssertEqualObjects([email6 domain], nil);
    XCTAssertEqualObjects([email7 domain], nil);
}

- (void)testIsGmail {
    MAVEContactEmail *email0 = [[MAVEContactEmail alloc] initWithValue:@"foo@example.com"];
    MAVEContactEmail *email1 = [[MAVEContactEmail alloc] initWithValue:@"foo"];
    MAVEContactEmail *email2 = [[MAVEContactEmail alloc] initWithValue:@"foo+123@gmail.com"];
    XCTAssertFalse([email0 isGmail]);
    XCTAssertFalse([email1 isGmail]);
    XCTAssertTrue([email2 isGmail]);
}

@end
