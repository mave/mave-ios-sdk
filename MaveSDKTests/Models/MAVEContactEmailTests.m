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
    XCTAssertEqualObjects(email.value, @"foo@bar.com");
    XCTAssertEqualObjects(email.typeName, @"email");
    XCTAssertEqualObjects([email humanReadableValue], @"foo@bar.com");
}

@end
