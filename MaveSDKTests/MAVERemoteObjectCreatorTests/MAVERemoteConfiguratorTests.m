//
//  MAVERemoteConfiguratorTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MAVERemoteConfigurator.h"

@interface MAVERemoteConfiguratorDemo : NSObject<MAVEDictionaryInitializable>
@property (nonatomic, copy) NSString *titleCopy;
@property (nonatomic, copy) NSString *bodyCopy;
@end

@implementation MAVERemoteConfiguratorDemo

-(instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        self.titleCopy = [data objectForKey:@"title_copy"];
        self.bodyCopy = [data objectForKey:@"body_copy"];

        // add a key to trigger an init failure
        if ([data objectForKey:@"bad_key"]) {
            self = nil;
        }
    }
    return self;
}

@end

@interface MAVERemoteConfiguratorTests : XCTestCase

@property (nonatomic, copy) NSString *userDefaultsKeyForTests;

@end

@implementation MAVERemoteConfiguratorTests

- (void)setUp {
    [super setUp];
    self.userDefaultsKeyForTests = @"MAVETESTSRemoteConfiguratorTestsKey";
    // in case anyone forgot to cleanup
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.userDefaultsKeyForTests];
}

- (void)tearDown {
    //clean up
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.userDefaultsKeyForTests];

    [super tearDown];
}

- (void)testInit {
    NSDictionary *defaultData = @{@"title_copy": @"This is a page",
                                  @"body_copy": @"This is body"};
    __block MAVEPromiseWithDefaultDictValues *calledWithpromise;
    MAVERemoteConfigurator *configurator = [[MAVERemoteConfigurator alloc]
        initWithClassToCreate:[MAVERemoteConfiguratorDemo class]
        preFetchBlock:^(MAVEPromiseWithDefaultDictValues *promise) {
            calledWithpromise = promise;
        } userDefaultsPersistanceKey:self.userDefaultsKeyForTests
        defaultData:defaultData
        preferLocallySavedData:NO];

    MAVERemoteConfiguratorDataPersistor *persistor =
    (MAVERemoteConfiguratorDataPersistor *)configurator.dataPersistor;

    XCTAssertEqualObjects(configurator.classToCreate, [MAVERemoteConfiguratorDemo class]);
    XCTAssertEqualObjects(persistor.defaultData, defaultData);
    XCTAssertEqualObjects(persistor.userDefaultsKey, self.userDefaultsKeyForTests);
    XCTAssertEqualObjects(configurator.promise, calledWithpromise);
    XCTAssertEqualObjects(configurator.promise.defaultValue, defaultData);
}

// Test the configurator from top to bottom in the case where promise is fulfilled
- (void)testInitAndCreateObjectSuccess {
    NSDictionary *defaultData = @{@"title_copy": @"This is page",
                                  @"body_copy": @"This is body"};
    NSDictionary *fulfilledValue = @{@"title_copy": @"This is fulfilled page",
                                     @"body_copy": @"This is fulfilled body"};
    MAVERemoteConfigurator *configurator = [[MAVERemoteConfigurator alloc]
        initWithClassToCreate:[MAVERemoteConfiguratorDemo class]
        preFetchBlock:^(MAVEPromiseWithDefaultDictValues *promise) {
            promise.fulfilledValue = fulfilledValue;
        } userDefaultsPersistanceKey:self.userDefaultsKeyForTests
        defaultData:defaultData
        preferLocallySavedData:NO];

    __block MAVERemoteConfiguratorDemo *demoObject;
    [configurator createObjectWithTimeout:0 completionBlock:^(id object) {
        demoObject = (MAVERemoteConfiguratorDemo *)object;
        XCTAssertEqualObjects(demoObject.titleCopy, @"This is fulfilled page");
        XCTAssertEqualObjects(demoObject.bodyCopy, @"This is fulfilled body");
    }];
}

- (void)testInitAndCreateObjectFailsToDefaultData {
    NSDictionary *defaultData = @{@"title_copy": @"This is page",
                                  @"body_copy": @"This is body"};
    MAVERemoteConfigurator *configurator = [[MAVERemoteConfigurator alloc]
        initWithClassToCreate:[MAVERemoteConfiguratorDemo class]
        preFetchBlock:^(MAVEPromiseWithDefaultDictValues *promise) {
            [promise rejectPromise];
        } userDefaultsPersistanceKey:self.userDefaultsKeyForTests
        defaultData:defaultData
        preferLocallySavedData:NO];

    __block MAVERemoteConfiguratorDemo *demoObject;
    [configurator createObjectWithTimeout:0 completionBlock:^(id object) {
        demoObject = (MAVERemoteConfiguratorDemo *)object;
        XCTAssertEqualObjects(demoObject.titleCopy, @"This is page");
        XCTAssertEqualObjects(demoObject.bodyCopy, @"This is body");
    }];
}

- (void)testInitAndCreateObjectFailsToSavedData {
    NSDictionary *defaultData = @{@"title_copy": @"This is page",
                                  @"body_copy": @"This is body"};

    // Save some data before hand into the user defaults key slot, using
    // the full configurator flow
    NSDictionary *preSaveddata = @{@"title_copy": @"This is pre-saved page",
                                     @"body_copy": @"This is pre-saved body"};
    MAVERemoteConfigurator *configurator0 = [[MAVERemoteConfigurator alloc]
        initWithClassToCreate:[MAVERemoteConfiguratorDemo class]
        preFetchBlock:^(MAVEPromiseWithDefaultDictValues *promise) {
            promise.fulfilledValue = preSaveddata;
        } userDefaultsPersistanceKey:self.userDefaultsKeyForTests
        defaultData:defaultData
        preferLocallySavedData:NO];
    [configurator0 createObjectWithTimeout:0 completionBlock:^(id object) {}];

    // This is the code run under test
    MAVERemoteConfigurator *configurator = [[MAVERemoteConfigurator alloc]
        initWithClassToCreate:[MAVERemoteConfiguratorDemo class]
        preFetchBlock:^(MAVEPromiseWithDefaultDictValues *promise) {
            [promise rejectPromise];
        } userDefaultsPersistanceKey:self.userDefaultsKeyForTests
        defaultData:defaultData
        preferLocallySavedData:NO];

    __block MAVERemoteConfiguratorDemo *demoObject;
    [configurator createObjectWithTimeout:0 completionBlock:^(id object) {
        demoObject = (MAVERemoteConfiguratorDemo *)object;
        XCTAssertEqualObjects(demoObject.titleCopy, @"This is pre-saved page");
        XCTAssertEqualObjects(demoObject.bodyCopy, @"This is pre-saved body");
    }];
}

@end
