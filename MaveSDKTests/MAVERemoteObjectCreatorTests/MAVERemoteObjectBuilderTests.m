//
//  MAVERemoteObjectBuilderTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"
#import "MAVERemoteObjectBuilder.h"
#import "MAVERemoteObjectBuilder_Internal.h"


// Demo object to initialize
@interface MAVERemoteObjectDemo : NSObject<MAVEDictionaryInitializable>
@property (nonatomic, copy) NSString *titleCopy;
@property (nonatomic, copy) NSString *bodyCopy;
@end

@implementation MAVERemoteObjectDemo
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


@interface MAVERemoteObjectBuilderTests : XCTestCase
    @property (nonatomic, copy) NSString *userDefaultsKeyForTests;

@end

@implementation MAVERemoteObjectBuilderTests

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

// High level test that goes all the way through
- (void)testCreateObjectNoPersistenceSuccessSanityCheck {
    NSDictionary *defaultData = @{@"title_copy": @"This is title",
                                  @"body_copy": @"This is body"};
    NSDictionary *realData = @{@"title_copy": @"This is real title",
                               @"body_copy": @"This is real body"};

    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc]
                                        initWithClassToCreate:[MAVERemoteObjectDemo class]
                                        preFetchBlock:^(MAVEPromise *promise) {
                                            [promise fulfillPromise:(NSValue *)realData];
                                        } defaultData:defaultData];

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder createObjectSynchronousWithTimeout:0];
    XCTAssertEqualObjects(obj.titleCopy, @"This is real title");
    XCTAssertEqualObjects(obj.bodyCopy, @"This is real body");

    // calling the create object a second time should return the same object
    MAVERemoteObjectDemo *obj2 = (MAVERemoteObjectDemo *)[builder createObjectSynchronousWithTimeout:0];
    XCTAssertEqualObjects(obj, obj2);
}

#pragma mark - Init Methods

- (void)testInitObjectBuilderNoPersistance {
    NSDictionary *defaultData = @{@"title_copy": @"This is title",
                                  @"body_copy": @"This is body"};
    __block MAVEPromise *calledWithpromise;
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc]
                                        initWithClassToCreate:[MAVERemoteObjectDemo class]
                                        preFetchBlock:^(MAVEPromise *promise) {
                                            calledWithpromise = promise;
                                        } defaultData:defaultData];

    XCTAssertEqualObjects(builder.classToCreate, [MAVERemoteObjectDemo class]);
    XCTAssertNotNil(builder.promise);
    XCTAssertEqualObjects(builder.promise, calledWithpromise);
    XCTAssertNil(builder.loadedFromDiskData);
    XCTAssertNil(builder.persistor);
    XCTAssertEqualObjects(builder.defaultData, defaultData);
}

- (void)testInitObjectBuilderWithPersistance {
    // First persist some data
    NSDictionary *persistedData = @{@"title_copy": @"This is persisted title",
                                  @"body_copy": @"This is persisted body"};
    NSDictionary *defaultData = @{};
    MAVERemoteObjectBuilderDataPersistor *persistor = [[MAVERemoteObjectBuilderDataPersistor alloc]
                                                       initWithUserDefaultsKey:self.userDefaultsKeyForTests];
    [persistor saveJSONDataToUserDefaults:persistedData];

    __block MAVEPromise *calledWithPromise;
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc]
    initWithClassToCreate:[MAVERemoteObjectDemo class]
                                        preFetchBlock:^(MAVEPromise *promise) {
                                            calledWithPromise = promise;
                                        } defaultData:defaultData
                                        saveIfSuccessfulToUserDefaultsKey:self.userDefaultsKeyForTests
                                        preferLocallySavedData:NO];

    XCTAssertEqualObjects(builder.classToCreate, [MAVERemoteObjectDemo class]);
    XCTAssertNotNil(builder.promise);
    XCTAssertEqualObjects(builder.promise, calledWithPromise);
    XCTAssertNotNil(builder.persistor);
    XCTAssertEqualObjects(builder.loadedFromDiskData, persistedData);
    XCTAssertEqualObjects(builder.defaultData, defaultData);
}

- (void)testInitObjectBuilderWithPersistancePreferLocalWithLocalData {
    // First persist some data
    NSDictionary *persistedData = @{@"title_copy": @"This is persisted title",
                                    @"body_copy": @"This is persisted body"};
    NSDictionary *defaultData = @{};
    MAVERemoteObjectBuilderDataPersistor *persistor = [[MAVERemoteObjectBuilderDataPersistor alloc]
                                                       initWithUserDefaultsKey:self.userDefaultsKeyForTests];
    [persistor saveJSONDataToUserDefaults:persistedData];

    __block MAVEPromise *calledWithPromise;
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc]
                                        initWithClassToCreate:[MAVERemoteObjectDemo class]
                                        preFetchBlock:^(MAVEPromise *promise) {
                                            calledWithPromise = promise;
                                        } defaultData:defaultData
                                        saveIfSuccessfulToUserDefaultsKey:self.userDefaultsKeyForTests
                                        preferLocallySavedData:YES];

    XCTAssertEqualObjects(builder.classToCreate, [MAVERemoteObjectDemo class]);
    // using prefer local and there's existing data, so remote call is skipped (no promise)
    XCTAssertNil(builder.promise);
    XCTAssertNil(calledWithPromise);
    XCTAssertNotNil(builder.persistor);
    XCTAssertEqualObjects(builder.loadedFromDiskData, persistedData);
    XCTAssertEqualObjects(builder.defaultData, defaultData);
}

- (void)testInitObjectBuilderWithPersistancePreferLocalNoLocalData {
    // No persisted data
    XCTAssertNil([[NSUserDefaults standardUserDefaults] objectForKey:self.userDefaultsKeyForTests]);
    NSDictionary *defaultData = @{};

    __block MAVEPromise *calledWithPromise;
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc]
                                        initWithClassToCreate:[MAVERemoteObjectDemo class]
                                        preFetchBlock:^(MAVEPromise *promise) {
                                            calledWithPromise = promise;
                                        } defaultData:defaultData
                                        saveIfSuccessfulToUserDefaultsKey:self.userDefaultsKeyForTests
                                        preferLocallySavedData:YES];

    XCTAssertEqualObjects(builder.classToCreate, [MAVERemoteObjectDemo class]);
    // using prefer local and there's no existing data, so remote call is made normally
    // and promise created
    XCTAssertNotNil(builder.promise);
    XCTAssertEqualObjects(builder.promise, calledWithPromise);
    XCTAssertNotNil(builder.persistor);
    XCTAssertNil(builder.loadedFromDiskData);
    XCTAssertEqualObjects(builder.defaultData, defaultData);
}

- (void)testInitObjectBuilderCreatesOwnObjectOnceOnPromiseDone {
    __block MAVEPromise *calledWithPromise;
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc]
                                        initWithClassToCreate:[MAVERemoteObjectDemo class]
                                        preFetchBlock:^(MAVEPromise *promise) {
                                            calledWithPromise = promise;
                                        } defaultData:@{}
                                        saveIfSuccessfulToUserDefaultsKey:self.userDefaultsKeyForTests
                                        preferLocallySavedData:NO];
    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock createObjectSynchronousWithTimeout:0]);

    [calledWithPromise fulfillPromise:(NSValue *)@"foo"];

    OCMVerifyAllWithDelay(builderMock, 0.1);
}

# pragma mark - Top level create object methods
- (void)testCreateSynchronous {
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    MAVEPromise *promise = [[MAVEPromise alloc] init];
    builder.promise = promise;
    NSDictionary *someData = @{@"foo": @8};
    MAVERemoteObjectDemo *demoObject = [[MAVERemoteObjectDemo alloc] init];
    id builderMock = OCMPartialMock(builder);
    id promiseMock = OCMPartialMock(promise);

    OCMExpect([promiseMock doneSynchronousWithTimeout:3.5]).andReturn(someData);
    OCMExpect([builderMock buildWithPrimaryThenFallBackToDefaultsWithData:someData])
        .andReturn(demoObject);

    MAVERemoteObjectDemo *returnedObject = [builder createObjectSynchronousWithTimeout:3.5];

    OCMVerifyAll(builderMock);
    OCMVerifyAll(promiseMock);
    XCTAssertEqualObjects(returnedObject, demoObject);
}

- (void)testObjectHelperAccessorForCreateSynchronous0 {
    MAVERemoteObjectDemo *obj = [[MAVERemoteObjectDemo alloc] init];

    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    id mock = OCMPartialMock(builder);
    OCMExpect([mock createObjectSynchronousWithTimeout:0]).andReturn(obj);

    XCTAssertEqualObjects(builder.object, obj);

    OCMVerifyAll(mock);
}

- (void)testCreateSynchronousWhenPromiseNull {
    MAVERemoteObjectDemo *demoObject = [[MAVERemoteObjectDemo alloc] init];

    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    MAVEPromise *promise = [[MAVEPromise alloc] init];
    builder.promise = promise;
    id builderMock = OCMPartialMock(builder);
    id promiseMock = OCMPartialMock(promise);

    OCMExpect([promiseMock doneSynchronousWithTimeout:3.5]).andReturn(nil);
    OCMExpect([builderMock buildWithPrimaryThenFallBackToDefaultsWithData:nil]).andReturn(demoObject);

    MAVERemoteObjectDemo *returnedObject = [builder createObjectSynchronousWithTimeout:3.5];

    XCTAssertEqualObjects(returnedObject, demoObject);
    OCMVerifyAll(builderMock);
    OCMVerifyAll(promiseMock);
}

// This is the create case when the preferLocallySavedData flag is YES
- (void)testCreateSynchronousWhenNoPromise {
    MAVERemoteObjectDemo *demoObject = [[MAVERemoteObjectDemo alloc] init];
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];

    id builderMock = OCMPartialMock(builder);
    OCMExpect([builderMock buildWithPrimaryThenFallBackToDefaultsWithData:nil])
        .andReturn(demoObject);

    MAVERemoteObjectDemo *returnedObject = [builder createObjectSynchronousWithTimeout:1234];

    OCMVerifyAll(builderMock);
    XCTAssertEqualObjects(returnedObject, demoObject);
}

- (void)testCreateSynchronousTwiceReturnsSameObject {

}

- (void)testCreateAsync {
    MAVERemoteObjectDemo *demoObject = [[MAVERemoteObjectDemo alloc] init];

    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    MAVEPromise *promise = [[MAVEPromise alloc] init];
    builder.promise = promise;
    NSDictionary *someData = @{@"foo": @8};
    id builderMock = OCMPartialMock(builder);
    id promiseMock = OCMPartialMock(promise);

    OCMExpect([promiseMock done:[OCMArg checkWithBlock:^BOOL(id obj) {
        void(^completionBlock)(NSValue *value) = obj;
        completionBlock((NSValue *)someData);
        return YES;
    }] withTimeout:0.5]);
    OCMExpect([builderMock buildWithPrimaryThenFallBackToDefaultsWithData:someData])
        .andReturn(demoObject);

    XCTestExpectation *expectation =
        [self expectationWithDescription:@"returned object should be the same as demo object"];
    __block MAVERemoteObjectDemo *returnedObject;
    [builder createObjectWithTimeout:0.5
                     completionBlock:^(id object) {
                         returnedObject = object;
                         if ([returnedObject isEqual:demoObject]) {
                             [expectation fulfill];
                         }
                     }];

    [self waitForExpectationsWithTimeout:0.75 handler:nil];
    OCMVerifyAll(builderMock);
    OCMVerifyAll(promiseMock);
}

- (void)testCreateAsyncWhenNoPromise {
    MAVERemoteObjectDemo *demoObject = [[MAVERemoteObjectDemo alloc] init];

    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];

    id builderMock = OCMPartialMock(builder);

    OCMExpect([builderMock buildWithPrimaryThenFallBackToDefaultsWithData:nil])
        .andReturn(demoObject);

    __block MAVERemoteObjectDemo *returnedObject;
    [builder createObjectWithTimeout:4.5
                     completionBlock:^(id object) {
                         returnedObject = object;
                         XCTAssertEqualObjects(returnedObject, demoObject);
                     }];

    OCMVerifyAll(builderMock);
}

# pragma mark - Object constructor methods
// Helpers for various scenarios of building object
- (void)testBuildWithPrimaryWhenObjectAlreadyBeenCreatedOnce {
    NSDictionary *data = @{@"title_copy": @"This is title",
                           @"body_copy": @"This is body"};
    MAVERemoteObjectDemo *demoObject = [[MAVERemoteObjectDemo alloc] initWithDictionary:data];
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    builder.createdObject = demoObject;
    builder.classToCreate = [MAVERemoteObjectDemo class];

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder buildWithPrimaryThenFallBackToDefaultsWithData:@{}];

    XCTAssertNotNil(obj);
    XCTAssertEqualObjects(builder.createdObject, obj);
}

- (void)testBuildWithPrimarySuccess {
    NSDictionary *data = @{@"title_copy": @"This is title",
                           @"body_copy": @"This is body"};
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    builder.classToCreate = [MAVERemoteObjectDemo class];
    id persistorMock = OCMClassMock([MAVERemoteObjectBuilderDataPersistor class]);
    builder.persistor = persistorMock;
    OCMExpect([persistorMock saveJSONDataToUserDefaults:data]);

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder buildWithPrimaryThenFallBackToDefaultsWithData:data];

    OCMVerifyAll(persistorMock);
    XCTAssertNotNil(obj);
    XCTAssertEqualObjects(builder.createdObject, obj);
    XCTAssertEqualObjects(obj.titleCopy, @"This is title");
    XCTAssertEqualObjects(obj.bodyCopy, @"This is body");
}

- (void)testBuildWithPrimaryThenLoadedFromDiskDefault {
    NSDictionary *primaryData = @{@"bad_key": @1};
    NSDictionary *data = @{@"title_copy": @"This is title",
                           @"body_copy": @"This is body"};
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    builder.classToCreate = [MAVERemoteObjectDemo class];
    builder.loadedFromDiskData = data;
    id persistorMock = OCMClassMock([MAVERemoteObjectBuilderDataPersistor class]);
    builder.persistor = persistorMock;
    [[persistorMock reject] saveJSONDataToUserDefaults:data];

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder buildWithPrimaryThenFallBackToDefaultsWithData:primaryData];

    OCMVerifyAll(persistorMock);
    XCTAssertNotNil(obj);
    // does not set the createdObject cache when using fallback data
    XCTAssertNil(builder.createdObject);
    XCTAssertEqualObjects(obj.titleCopy, @"This is title");
    XCTAssertEqualObjects(obj.bodyCopy, @"This is body");

}

- (void)testBuildWithPrimaryThenHardCodedDefault {
    NSDictionary *primaryData = @{@"bad_key": @1};
    NSDictionary *fromDiskData = @{@"bad_key": @2};
    NSDictionary *data = @{@"title_copy": @"This is title",
                           @"body_copy": @"This is body"};
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    builder.classToCreate = [MAVERemoteObjectDemo class];
    builder.loadedFromDiskData = fromDiskData;
    builder.defaultData = data;
    id persistorMock = OCMClassMock([MAVERemoteObjectBuilderDataPersistor class]);
    builder.persistor = persistorMock;
    [[persistorMock reject] saveJSONDataToUserDefaults:data];

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder buildWithPrimaryThenFallBackToDefaultsWithData:primaryData];

    OCMVerifyAll(persistorMock);
    XCTAssertNotNil(obj);
    // does not set createdObject cache
    XCTAssertNil(builder.createdObject);
    XCTAssertEqualObjects(obj.titleCopy, @"This is title");
    XCTAssertEqualObjects(obj.bodyCopy, @"This is body");
}

- (void)testBuildWithPrimaryEverythingFails {
    NSDictionary *primaryData = @{@"bad_key": @1};
    NSDictionary *fromDiskData = @{@"bad_key": @2};
    NSDictionary *data = @{@"bad_key": @3};
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    builder.classToCreate = [MAVERemoteObjectDemo class];
    builder.loadedFromDiskData = fromDiskData;
    builder.defaultData = data;

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder buildWithPrimaryThenFallBackToDefaultsWithData:primaryData];
    XCTAssertNil(obj);
}

- (void)testBuildWithPrimaryNilAndDiskLoadedNil {
    NSDictionary *data = @{@"title_copy": @"This is title",
                           @"body_copy": @"This is body"};
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    builder.classToCreate = [MAVERemoteObjectDemo class];
    builder.defaultData = data;

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder buildWithPrimaryThenFallBackToDefaultsWithData:nil];
    XCTAssertNotNil(obj);
    XCTAssertEqualObjects(obj.titleCopy, @"This is title");
    XCTAssertEqualObjects(obj.bodyCopy, @"This is body");
}

- (void)testBuildWithPrimaryEmptyDict {
    NSDictionary *primaryData = @{};
    NSDictionary *data = @{@"title_copy": @"This is title",
                           @"body_copy": @"This is body"};
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    builder.classToCreate = [MAVERemoteObjectDemo class];
    builder.defaultData = data;

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder buildWithPrimaryThenFallBackToDefaultsWithData:primaryData];
    XCTAssertNotNil(obj);
    XCTAssertNil(obj.titleCopy);
    XCTAssertNil(obj.bodyCopy);
}

// Helpers for single attempt to construct
- (void)testBuildObjectsUsingData {
    NSDictionary *data = @{@"title_copy": @"This is title",
                           @"body_copy": @"This is body"};
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    builder.classToCreate = [MAVERemoteObjectDemo class];

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder buildObjectUsingData:data];
    XCTAssertNotNil(obj);
    XCTAssertEqualObjects(obj.titleCopy, @"This is title");
    XCTAssertEqualObjects(obj.bodyCopy, @"This is body");
}

- (void)testBuildObjectsUsingDataBad {
    NSDictionary *data = @{@"bad_key": @1};
    MAVERemoteObjectBuilder *builder = [[MAVERemoteObjectBuilder alloc] init];
    builder.classToCreate = [MAVERemoteObjectDemo class];

    MAVERemoteObjectDemo *obj = (MAVERemoteObjectDemo *)[builder buildObjectUsingData:data];
    XCTAssertNil(obj);
}


@end
