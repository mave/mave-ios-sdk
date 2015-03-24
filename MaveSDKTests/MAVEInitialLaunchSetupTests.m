//
//  MAVEInitialLaunchSetupTests.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/23/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MaveSDK.h"
#import "MAVEIDUtils.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@interface MAVEInitialLaunchSetupTests : XCTestCase

@end

@implementation MAVEInitialLaunchSetupTests

- (void)testIsInitialLaunchYesWhenNoStoredAdid {
    // We use the presence of an app_device_id having been read from disk
    // to mean that the app has been launched before, if it's not on disk
    // then this is the first time the app has been launched
    [MaveSDK resetSharedInstanceForTesting];
    [MAVEIDUtils clearStoredAppDeviceID];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertTrue([MaveSDK sharedInstance].isInitialAppLaunch);
}

- (void)testIsInitialLaunchNoOnSubsequentLaunches {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertNotNil([MaveSDK sharedInstance].appDeviceID);

    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
    XCTAssertFalse([MaveSDK sharedInstance].isInitialAppLaunch);
}

@end
