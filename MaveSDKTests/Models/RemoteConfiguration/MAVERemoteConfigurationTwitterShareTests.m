//
//  MAVERemoteConfigurationTwitterShareTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationTwitterShare.h"

@interface MAVERemoteConfigurationTwitterShareTests : XCTestCase

@end

@implementation MAVERemoteConfigurationTwitterShareTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationTwitterShare defaultJSONData];
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertNotNil(template);

    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");
    XCTAssertEqualObjects([template objectForKey:@"copy"], @"I love DemoApp. Try it out ");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationTwitterShare *obj = [[MAVERemoteConfigurationTwitterShare alloc] initWithDictionary:[MAVERemoteConfigurationTwitterShare defaultJSONData]];

    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.text, @"I love DemoApp. Try it out ");
}

- (void)testInitFailsIfTemplateMalformed {
    // missing the "copy" parameter
    NSDictionary *data = @{@"template_id": @"foo"};
    MAVERemoteConfigurationTwitterShare *obj = [[MAVERemoteConfigurationTwitterShare alloc] initWithDictionary:data];

    XCTAssertNil(obj);
}

@end
