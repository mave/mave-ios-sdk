//
//  MAVERemoteConfiguratorDataPersistorTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <XCTest/XCTest.h>
#include <stdlib.h>
#import "MAVERemoteObjectBuilderDataPersistor.h"

@interface MAVERemoteConfiguratorDataPersistorTests : XCTestCase

@end

@implementation MAVERemoteConfiguratorDataPersistorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    NSString *key = @"foo";
    MAVERemoteObjectBuilderDataPersistor *persistor =
        [[MAVERemoteObjectBuilderDataPersistor alloc] initWithUserDefaultsKey:key];
    XCTAssertEqualObjects(persistor.userDefaultsKey, key);
}

- (void)testSaveAndFetchData {
    NSString *key = @"MAVETESTSRCDPKEY";
    // try all kinds of property list data
    NSNumber *randomInt = [NSNumber numberWithInt:arc4random_uniform(74)];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@{@"data": @[@1, @YES, @"foo"]} forKey:@"foo"];
    [data setObject:randomInt forKey:@"randomint"];

    MAVERemoteObjectBuilderDataPersistor *persistor =
        [[MAVERemoteObjectBuilderDataPersistor alloc] initWithUserDefaultsKey:key];

    [persistor saveJSONDataToUserDefaults:data];
    XCTAssertEqualObjects([persistor loadJSONDataFromUserDefaults], data);

    // clean up
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void)testSaveInvalidDataFailsSilently {
    NSString *key = @"MAVETESTSRCDPKEY2";
    // arbitrary objects are not property list data
    NSDictionary *badData = @{@"foo": [[NSObject alloc] init]};

    MAVERemoteObjectBuilderDataPersistor *persistor =
    [[MAVERemoteObjectBuilderDataPersistor alloc] initWithUserDefaultsKey:key];

    [persistor saveJSONDataToUserDefaults:badData];
    XCTAssertEqualObjects([persistor loadJSONDataFromUserDefaults], nil);
}

@end
