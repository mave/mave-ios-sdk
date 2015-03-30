//
//  MAVERemoteConfigurationServerSMS.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/14/15.
//
//

#import "MAVERemoteConfigurationServerSMS.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVETemplatingUtils.h"

NSString * const MAVERemoteConfigKeyServerSMSTemplate = @"template";
NSString * const MAVERemoteConfigKeyServerSMSTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyServerSMSCopy = @"copy_template";


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
            self.textTemplate = text;
        }
        if (!self.textTemplate) {
            return nil;
        }

    }
    return self;
}

// Returns the sms copy with template values filled in
- (NSString *)text {
    return [MAVETemplatingUtils interpolateWithSingletonDataTemplateString:self.textTemplate];
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
