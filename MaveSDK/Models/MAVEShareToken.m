//
//  MAVEShareToken.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import "MAVEShareToken.h"
#import "MaveSDK.h"

NSString * const MAVEUserDefaultsKeyShareToken = @"MAVEUserDefaultsKeyShareToken";
NSString *const MAVEShareTokenKeyShareToken = @"share_token";

@implementation MAVEShareToken

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        self.shareToken = [data objectForKey:@"share_token"];
    }
    return self;
}

+ (MAVERemoteConfigurator *)remoteBuilder {
    return [[MAVERemoteConfigurator alloc]
            initWithClassToCreate:[self class]
            preFetchBlock:^(MAVEPromiseWithDefaultDictValues *promise) {
                [[MaveSDK sharedInstance].APIInterface
                 getRemoteConfigurationWithCompletionBlock:^(NSError *error, NSDictionary *responseData) {
                     if (error) {
                         [promise rejectPromise];
                     } else {
                         promise.fulfilledValue = responseData;
                     }
                 }];
            } userDefaultsPersistanceKey:MAVEUserDefaultsKeyShareToken
            defaultData:[self defaultJSONData]
            preferLocallySavedData:YES];
}

+ (NSDictionary *)defaultJSONData {
    return @{};
}

@end
