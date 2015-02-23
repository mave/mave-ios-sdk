//
//  MAVESuggestedInvitesTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/21/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVESuggestedInvites.h"

@interface MAVESuggestedInvitesTests : XCTestCase

@end

@implementation MAVESuggestedInvitesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaultData = [MAVESuggestedInvites defaultData];
    NSDictionary *expectedData = @{@"closest_contacts": @[]};
    XCTAssertEqualObjects(defaultData, expectedData);
}

- (void)testInitWithDictionaryValid {
    NSDictionary *dict = [MAVESuggestedInvites defaultData];
    MAVESuggestedInvites *suggested = [[MAVESuggestedInvites alloc] initWithDictionary:dict];
    XCTAssertEqualObjects(suggested.suggestions, @[]);

    dict = @{@"closest_contacts": @[@"blah", @"foo"]};
    suggested = [[MAVESuggestedInvites alloc] initWithDictionary:dict];
    NSArray *expected = @[@"blah", @"foo"];
    XCTAssertEqualObjects(suggested.suggestions, expected);
}

- (void)testInitWithInvalidDictionary {
    // should not initialize  if it gets bad data
    NSDictionary *dict = @{@"closest_contacts": [NSNull null]};
    MAVESuggestedInvites *suggested = [[MAVESuggestedInvites alloc] initWithDictionary:dict];
    XCTAssertNil(suggested);

    suggested = [[MAVESuggestedInvites alloc] initWithDictionary:@{}];
    XCTAssertNil(suggested);
}

@end
