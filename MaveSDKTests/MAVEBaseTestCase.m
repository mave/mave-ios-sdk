//
//  MAVETestBase.m
//  MaveSDK
//
//  Created by Danny Cosson on 3/23/15.
//
//

#import "MAVEBaseTestCase.h"
#import "MaveSDK.h"

@interface MaveSDK(Testing)
+ (void)resetSharedInstanceForTesting;
@end

@implementation MAVEBaseTestCase

- (void)setUp {
    [super setUp];
    [self resetTestState];
}

- (void)resetTestState {
    [MaveSDK resetSharedInstanceForTesting];
    [MaveSDK setupSharedInstanceWithApplicationID:@"foo123"];
}

@end
