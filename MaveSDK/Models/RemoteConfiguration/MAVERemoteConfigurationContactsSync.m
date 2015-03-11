//
//  MAVERemoteConfigurationContactSync.m
//  MaveSDK
//
//  Created by Danny Cosson on 2/18/15.
//
//

#import "MAVERemoteConfigurationContactsSync.h"

NSString * const MAVERemoteConfigKeyContactsSyncEnabled = @"enabled";

@implementation MAVERemoteConfigurationContactsSync

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        id enabledObj = [data objectForKey:MAVERemoteConfigKeyContactsSyncEnabled];
        if (enabledObj == [NSNull null]) {
            enabledObj = nil;
        }
        self.enabled = [enabledObj boolValue];
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyContactsSyncEnabled: @NO,
    };
}

@end
