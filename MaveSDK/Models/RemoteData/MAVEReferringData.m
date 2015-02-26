//
//  MAVEReferralData.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/26/15.
//
//

#import "MAVEReferringData.h"
#import "MaveSDK.h"

const NSString *MAVEReferringDataKeyReferringUser = @"referring_user";
const NSString *MAVEReferringDataKeyCurrentUser = @"current_user";

@implementation MAVEReferringData

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        @try {
            NSDictionary *referringUserDict = [data objectForKey:MAVEReferringDataKeyReferringUser];
            if (referringUserDict && (id)referringUserDict != [NSNull null]) {
                self.referringUser = [[MAVEUserData alloc] initWithDictionary:referringUserDict];
            }
        } @catch (NSException *exception) {
            self.referringUser = nil;
        }

        @try {
            NSDictionary *currentUserDict = [data objectForKey:MAVEReferringDataKeyCurrentUser];
            if (currentUserDict && (id)currentUserDict != [NSNull null]) {
                self.currentUser = [[MAVEUserData alloc] initWithDictionary:currentUserDict];
            }
        } @catch (NSException *exception) {
            self.currentUser = nil;
        }
    }
    return self;
}

+ (MAVERemoteObjectBuilder *)remoteBuilder {
    return [[MAVERemoteObjectBuilder alloc] initWithClassToCreate:[self class] preFetchBlock:^(MAVEPromise *promise) {
        [[MaveSDK sharedInstance].APIInterface getReferringData:^(NSError *error, NSDictionary *responseData) {
            if (!error && responseData) {
                [promise fulfillPromise:(NSValue *)responseData];
            } else {
                [promise rejectPromise];
            }
        }];
    } defaultData:[self defaultData]];
}

+ (NSDictionary *)defaultData {
    return @{
        MAVEReferringDataKeyReferringUser: [NSNull null],
        MAVEReferringDataKeyCurrentUser: [NSNull null],
    };
}

@end
