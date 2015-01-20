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

        NSString *templateID = [template objectForKey:MAVERemoteConfigKeyTwitterShareTemplateID];
        if (![templateID isEqual:[NSNull null]]) {
            self.templateID = templateID;
        }
        NSString *text = [template objectForKey:MAVERemoteConfigKeyTwitterShareCopy];
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
    NSString *text = [NSString stringWithFormat:@"I love %@. Try it out",
                      [MAVEClientPropertyUtils appName]];
    return @{
        MAVERemoteConfigKeyTwitterShareTemplate: @{
            MAVERemoteConfigKeyTwitterShareTemplateID: @"0",
            MAVERemoteConfigKeyTwitterShareCopy: text,
        },
    };
}

@end
