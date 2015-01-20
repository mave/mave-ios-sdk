//
//  MAVERemoteConfigurationClientShare.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import "MAVERemoteConfigurationClientSMS.h"
#import "MAVEClientPropertyUtils.h"

NSString * const MAVERemoteConfigKeyClientSMSTemplate = @"template";
NSString * const MAVERemoteConfigKeyClientSMSTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyClientSMSCopy = @"copy";


@implementation MAVERemoteConfigurationClientSMS

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyClientSMSTemplate];

        NSString *templateID = [template objectForKey:MAVERemoteConfigKeyClientSMSTemplateID];
        if (![templateID isEqual:[NSNull null]]) {
            self.templateID = templateID;
        }
        NSString *text = [template objectForKey:MAVERemoteConfigKeyClientSMSCopy];
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
        MAVERemoteConfigKeyClientSMSTemplate: @{
            MAVERemoteConfigKeyClientSMSTemplateID: @"0",
            MAVERemoteConfigKeyClientSMSCopy: text,
        },

    };
}

@end
