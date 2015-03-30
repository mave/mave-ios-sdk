//
//  MAVERemoteConfigurationFacebookShare.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import "MAVERemoteConfigurationFacebookShare.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVETemplatingUtils.h"

NSString * const MAVERemoteConfigKeyFacebookShareTemplate = @"template";
NSString * const MAVERemoteConfigKeyFacebookShareTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyFacebookShareCopy = @"initial_text_template";

@implementation MAVERemoteConfigurationFacebookShare

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyFacebookShareTemplate];
        NSString *templateID = [template objectForKey:MAVERemoteConfigKeyFacebookShareTemplateID];
        if (![templateID isEqual:[NSNull null]]) {
            self.templateID = templateID;
        }
        NSString *text = [template objectForKey:MAVERemoteConfigKeyFacebookShareCopy];
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
    NSString *text = [NSString stringWithFormat:@"I love %@. You should try it.",
                      [MAVEClientPropertyUtils appName]];
    return @{
        MAVERemoteConfigKeyFacebookShareTemplate: @{
            MAVERemoteConfigKeyFacebookShareTemplateID: @"0",
            MAVERemoteConfigKeyFacebookShareCopy: text,
        },
    };
}

@end
