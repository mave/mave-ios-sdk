//
//  MAVERemoteConfigurationTwitterShare.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import "MAVERemoteConfigurationTwitterShare.h"
#import "MAVEClientPropertyUtils.h"

NSString * const MAVERemoteConfigKeyTwitterShareTemplate = @"template";
NSString * const MAVERemoteConfigKeyTwitterShareTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyTwitterShareCopy = @"copy";

@implementation MAVERemoteConfigurationTwitterShare

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyTwitterShareTemplate];
        self.templateID = [template objectForKey:MAVERemoteConfigKeyTwitterShareTemplateID];
        self.text = [template objectForKey:MAVERemoteConfigKeyTwitterShareCopy];
        if (!self.templateID || !self.text) {
            return nil;
        }

    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    NSString *text = [NSString stringWithFormat:@"I love %@. Try it out ",
                      [MAVEClientPropertyUtils appName]];
    return @{
        MAVERemoteConfigKeyTwitterShareTemplate: @{
            MAVERemoteConfigKeyTwitterShareTemplateID: @"0",
            MAVERemoteConfigKeyTwitterShareCopy: text,
        },
    };
}

@end
