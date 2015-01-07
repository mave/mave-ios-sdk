//
//  MAVERemoteConfiguratorDataPersistorTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <XCTest/XCTest.h>
#include <stdlib.h>
#import "MAVERemoteConfiguratorDataPersistor.h"

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

- (void)testInitAndFetchIfNoSavedData {
    NSString *key = @"foo";
    NSDictionary *dict = @{@"foo": @1};
    MAVERemoteConfiguratorDataPersistor *persistor =
        [[MAVERemoteConfiguratorDataPersistor alloc] initWithUserDefaultsKey:key
                                                             defaultJSONData:dict];
    XCTAssertEqualObjects(persistor.userDefaultsKey, key);
    XCTAssertEqualObjects(persistor.defaultData, dict);
    XCTAssertEqualObjects([persistor JSONData], dict);
}

- (void)testSaveAndFetchData {
    NSString *key = @"MAVETESTSRCDPKEY";
    // try all kinds of property list data
    NSNumber *randomInt = [NSNumber numberWithInt:arc4random_uniform(74)];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@{@"data": @[@1, @YES, @"foo"]} forKey:@"foo"];
    [data setObject:randomInt forKey:@"randomint"];

    MAVERemoteConfiguratorDataPersistor *persistor =
        [[MAVERemoteConfiguratorDataPersistor alloc] initWithUserDefaultsKey:key
                                                             defaultJSONData:nil];

    [persistor saveJSONDataToUserDefaults:data];
    XCTAssertEqualObjects([persistor loadJSONDataFromUserDefaults], data);
    XCTAssertEqualObjects([persistor JSONData], data);

    // clean up
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void)testSaveInvalidDataFailsSilently {
    NSString *key = @"MAVETESTSRCDPKEY2";
    // arbitrary objects are not property list data
    NSDictionary *defaultData = @{@"foo": @1};
    NSDictionary *badData = @{@"foo": [[NSObject alloc] init]};

    MAVERemoteConfiguratorDataPersistor *persistor =
    [[MAVERemoteConfiguratorDataPersistor alloc] initWithUserDefaultsKey:key
                                                         defaultJSONData:defaultData];

    [persistor saveJSONDataToUserDefaults:badData];
    XCTAssertEqualObjects([persistor loadJSONDataFromUserDefaults], nil);
    XCTAssertEqualObjects([persistor JSONData], defaultData);
}

///
/// Serialization tests
///
//- (void)testSaveAndLoadValidJSONDataUserDefaults {
//    XCTAssertEqualObjects([MAVERemoteConfiguration userDefaultsKey],
//                          @"MAVEUserDefaultsTESTSKeyRemoteConfiguration");
//
//    // try all kinds of property list data
//    NSNumber *randomInt = [NSNumber numberWithInt:arc4random_uniform(74)];
//    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
//    [data setObject:@{@"data": @[@1, @YES, @"foo"]} forKey:@"foo"];
//    [data setObject:randomInt forKey:@"randomint"];
//
//    [MAVERemoteConfiguration saveJSONDataToUserDefaults:data];
//    NSDictionary *returnedData = [MAVERemoteConfiguration loadJSONDataFromUserDefaults];
//    XCTAssertNotNil(returnedData);
//    XCTAssertEqualObjects(returnedData, data);
//}
//
//- (void)testDefaultJSONDataIfSavedData {
//    NSDictionary *data = @{@"foo": @2};
//    [MAVERemoteConfiguration saveJSONDataToUserDefaults:data];
//
//    NSDictionary *returnedData = [MAVERemoteConfiguration defaultJSONData];
//
//    XCTAssertEqualObjects(returnedData, data);
//}
//
//- (void)testDefaultJSONDataIfNoSavedData {
//    NSDictionary *defaultData = [MAVERemoteConfiguration defaultDefaultJSONData];
//    NSDictionary *returnedData = [MAVERemoteConfiguration defaultJSONData];
//
//    XCTAssertNotNil(defaultData);
//    XCTAssertEqualObjects(returnedData, defaultData);
//}

@end
