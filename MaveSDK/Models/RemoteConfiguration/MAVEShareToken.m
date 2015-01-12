//
//  MAVEShareToken.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/7/15.
//
//

#import "MAVEShareToken.h"
#import "MaveSDK.h"

#ifdef UNITTESTING
NSString * const MAVEUserDefaultsKeyShareToken = @"MAVETESTSUserDefaultsKeyShareToken";
#else
NSString * const MAVEUserDefaultsKeyShareToken = @"MAVEUserDefaultsKeyShareToken";
#endif

NSString * const MAVEShareTokenKeyShareToken = @"share_token";

@implementation MAVEShareToken

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        self.shareToken = [data objectForKey:@"share_token"];
        // nil is different than empty string
        if (self.shareToken == nil) {
            return nil;
        }
    }
    return self;
}

+ (MAVERemoteObjectBuilder *)remoteBuilder {
    return [[MAVERemoteObjectBuilder alloc] initWithClassToCreate:[self class]
            preFetchBlock:^(MAVEPromise *promise) {
                [[MaveSDK sharedInstance].APIInterface
                getRemoteConfigurationWithCompletionBlock:^(NSError *error, NSDictionary *responseData) {
                    if (error) {
                        [promise rejectPromise];
                    } else {
                        [promise fulfillPromise:(NSValue *)responseData];
                    }
                }];
            } defaultData:[self defaultJSONData]
            saveIfSuccessfulToUserDefaultsKey:MAVEUserDefaultsKeyShareToken
                                           preferLocallySavedData:YES];
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVEShareTokenKeyShareToken: @"",
    };
}

+ (void)clearUserDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MAVEUserDefaultsKeyShareToken];
}

@end
