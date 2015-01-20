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

        NSString *templateID = [template objectForKey:MAVERemoteConfigKeyServerSMSTemplateID];
        if (![templateID isEqual:[NSNull null]]) {
            self.templateID = templateID;
        }
        NSString *text = [template objectForKey:MAVERemoteConfigKeyServerSMSCopy];
        if (![text isEqual:[NSNull null]]) {
            self.text = text;
        }
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
