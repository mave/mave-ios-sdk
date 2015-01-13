//
//  MAVERemoteConfigurationFacebookShare.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import "MAVERemoteConfigurationFacebookShare.h"
#import "MAVEClientPropertyUtils.h"

NSString * const MAVERemoteConfigKeyFacebookShareTemplate = @"template";
NSString * const MAVERemoteConfigKeyFacebookShareTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyFacebookShareCopy = @"initial_text";

@implementation MAVERemoteConfigurationFacebookShare

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyFacebookShareTemplate];
        self.templateID = [template objectForKey:MAVERemoteConfigKeyFacebookShareTemplateID];
        self.text = [template objectForKey:MAVERemoteConfigKeyFacebookShareCopy];
        if (!self.text) {
            return nil;
        }

    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    NSString *text = [NSString stringWithFormat:@"I love %@. You should try it. ",
                      [MAVEClientPropertyUtils appName]];
    return @{
        MAVERemoteConfigKeyFacebookShareTemplate: @{
            MAVERemoteConfigKeyFacebookShareTemplateID: @"0",
            MAVERemoteConfigKeyFacebookShareCopy: text,
        },
    };
}

@end
