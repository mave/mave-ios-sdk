//
//  MAVERemoteConfigurationClientShare.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import "MAVERemoteConfigurationClientSMS.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVETemplatingUtils.h"

NSString * const MAVERemoteConfigKeyClientSMSTemplate = @"template";
NSString * const MAVERemoteConfigKeyClientSMSTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyClientSMSCopyTemplate = @"copy_template";


@implementation MAVERemoteConfigurationClientSMS

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyClientSMSTemplate];

        NSString *templateID = [template objectForKey:MAVERemoteConfigKeyClientSMSTemplateID];
        if (![templateID isEqual:[NSNull null]]) {
            self.templateID = templateID;
        }
        NSString *text = [template objectForKey:MAVERemoteConfigKeyClientSMSCopyTemplate];
        if (![text isEqual:[NSNull null]]) {
            self.textTemplate = text;
        }
        if (!self.textTemplate) {
            return nil;
        }
        
    }
    return self;
}

- (NSString *)text {
    return [MAVETemplatingUtils interpolateWithSingletonDataTemplateString:self.textTemplate];
}

+ (NSDictionary *)defaultJSONData {
    NSString *text = [NSString stringWithFormat:@"Join me on %@!",
                      [MAVEClientPropertyUtils appName]];
    return @{
        MAVERemoteConfigKeyClientSMSTemplate: @{
            MAVERemoteConfigKeyClientSMSTemplateID: @"0",
            MAVERemoteConfigKeyClientSMSCopyTemplate: text,
        },

    };
}

@end
