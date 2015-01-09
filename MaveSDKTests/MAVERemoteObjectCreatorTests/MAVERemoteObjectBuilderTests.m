//
//  MAVERemoteObjectBuilderTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/9/15.
//
//

#import <XCTest/XCTest.h>
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

- (void)testInitObjectBuilderNoPersistance {
    NSDictionary *defaultData = @{@"title_copy": @"This is a page",
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
    XCTAssertNil(builder.persistor);
}


@end
