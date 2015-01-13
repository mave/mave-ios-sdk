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

- (void)testSaveAndInspectData {
    NSString *key = @"MAVETESTSRCDPKEY";
    MAVERemoteObjectBuilderDataPersistor *persistor =
        [[MAVERemoteObjectBuilderDataPersistor alloc] initWithUserDefaultsKey:key];

    [persistor saveJSONDataToUserDefaults:@{@"foo": @"bar"}];
    NSString *expectedString = @"{\"foo\":\"bar\"}";

    NSData *returnedData = [[NSUserDefaults standardUserDefaults] dataForKey:key];
    NSString *parsedRetData = [[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(parsedRetData, expectedString);
}

- (void)testSaveAndFetchData {
    NSString *key = @"MAVETESTSRCDPKEY2";
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
    NSString *key = @"MAVETESTSRCDPKEY3";
    // arbitrary objects are not property list data
    NSDictionary *badData = @{@"foo": [[NSObject alloc] init]};

    MAVERemoteObjectBuilderDataPersistor *persistor =
    [[MAVERemoteObjectBuilderDataPersistor alloc] initWithUserDefaultsKey:key];

    [persistor saveJSONDataToUserDefaults:badData];
    XCTAssertEqualObjects([persistor loadJSONDataFromUserDefaults], nil);
}

- (void)testWipeJSONData {
    NSString *key = @"MAVETESTSRCDPKEY3";
    // set up and store data
    NSData *data = [@"some data" dataUsingEncoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];

    // it's there
    NSData *returned1 = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    XCTAssertNotNil(returned1);
    XCTAssertEqualObjects(returned1, data);

    MAVERemoteObjectBuilderDataPersistor *persistor =
    [[MAVERemoteObjectBuilderDataPersistor alloc] initWithUserDefaultsKey:key];
    [persistor wipeJSONData];

    // it's wiped
    NSData *returned2 = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    XCTAssertNil(returned2);
}

- (void)testFetchDataWipesDataIfInvalid {
    NSString *key = @"MAVETESTSRCDPKEY3";
    // this is not valid json
    NSData *badData = [@"i am not json" dataUsingEncoding:NSUTF8StringEncoding];

    [[NSUserDefaults standardUserDefaults] setObject:badData forKey:key];

    NSData *returned1 = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    XCTAssertNotNil(returned1);
    XCTAssertEqualObjects(returned1, badData);

    MAVERemoteObjectBuilderDataPersistor *persistor =
        [[MAVERemoteObjectBuilderDataPersistor alloc] initWithUserDefaultsKey:key];

    // returned json parsed data is nil
    NSDictionary *returnedEmpty = [persistor loadJSONDataFromUserDefaults];
    XCTAssertNil(returnedEmpty);

    // and now data has been wiped
    NSData *returned2 = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    XCTAssertNil(returned2);
}

@end
