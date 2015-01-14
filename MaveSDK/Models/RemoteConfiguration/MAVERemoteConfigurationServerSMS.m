//
//  MAVERemoteConfigurationServerSMS.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/14/15.
//
//

#import "MAVERemoteConfigurationServerSMS.h"
#import "MAVEClientPropertyUtils.h"

NSString * const MAVERemoteConfigKeyServerSMSTemplate = @"template";
NSString * const MAVERemoteConfigKeyServerSMSTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyServerSMSCopy = @"copy";


@implementation MAVERemoteConfigurationServerSMS

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyServerSMSTemplate];
        self.templateID = [template objectForKey:MAVERemoteConfigKeyServerSMSTemplateID];
        self.text = [template objectForKey:MAVERemoteConfigKeyServerSMSCopy];
        if (!self.text) {
            return nil;
        }

    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    NSString *text = [NSString stringWithFormat:@"Join me on %@!",
                      [MAVEClientPropertyUtils appName]];
    return @{
             MAVERemoteConfigKeyServerSMSTemplate: @{
                     MAVERemoteConfigKeyServerSMSTemplateID: @"0",
                     MAVERemoteConfigKeyServerSMSCopy: text,
                     },
             
             };
}

@end
