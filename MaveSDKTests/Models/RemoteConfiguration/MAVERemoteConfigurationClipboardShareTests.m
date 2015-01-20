//
//  MAVERemoteConfigurationClipboardShareTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurationClipboardShare.h"

@interface MAVERemoteConfigurationClipboardShareTests : XCTestCase

@end

@implementation MAVERemoteConfigurationClipboardShareTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultData {
    NSDictionary *defaults = [MAVERemoteConfigurationClipboardShare defaultJSONData];
    NSDictionary *template = [defaults objectForKey:@"template"];
    XCTAssertNotNil(template);

    XCTAssertEqualObjects([template objectForKey:@"template_id"], @"0");
    XCTAssertEqualObjects([template objectForKey:@"copy"], @"");
}

- (void)testInitFromDefaultData {
    MAVERemoteConfigurationClipboardShare *obj = [[MAVERemoteConfigurationClipboardShare alloc] initWithDictionary:[MAVERemoteConfigurationClipboardShare defaultJSONData]];

    XCTAssertEqualObjects(obj.templateID, @"0");
    XCTAssertEqualObjects(obj.text, @"");
}

- (void)testInitFailsIfTemplateMalformed {
    // missing the "copy" parameter
    NSDictionary *data = @{@"template": @{@"template_id": @"foo"}};
    MAVERemoteConfigurationClipboardShare *obj = [[MAVERemoteConfigurationClipboardShare alloc] initWithDictionary:data];
    XCTAssertNil(obj);

    data = @{@"template": @{@"template_id": @"foo", @"copy": [NSNull null]}};
    obj = [[MAVERemoteConfigurationClipboardShare alloc] initWithDictionary:data];
    XCTAssertNil(obj);

}

- (void)testNSNullVauesChangedToNil {
    NSDictionary *dict = @{
                           @"enabled": @YES,
                           @"template": @{
                                   @"template_id": [NSNull null],
                                   @"copy": @"foo",
                                   }
                           };
    MAVERemoteConfigurationClipboardShare *obj = [[MAVERemoteConfigurationClipboardShare alloc] initWithDictionary:dict];
    // should be nil, not nsnull
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.templateID);
}


@end
