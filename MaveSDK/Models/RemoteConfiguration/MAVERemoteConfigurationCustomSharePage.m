//
//  MAVERemoteConfigurationCustomSharePage.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/13/15.
//
//

#import "MAVERemoteConfigurationCustomSharePage.h"
#import "MAVEClientPropertyUtils.h"

const NSString *MAVERemoteConfigKeyCustomSharePageEnabled = @"enabled";
const NSString *MAVERemoteConfigKeyCustomSharePageTemplate = @"template";
const NSString *MAVERemoteConfigKeyCustomSharePageTemplateID = @"template_id";
const NSString *MAVERemoteConfigKeyCustomSharePageExplanationCopy = @"explanation_copy";

@implementation MAVERemoteConfigurationCustomSharePage

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        // check for is-enabled key. Empty != key explicitly set to false
        id enabledValue = [data objectForKey:MAVERemoteConfigKeyCustomSharePageEnabled];
        if (enabledValue == nil) {
            return nil;
        }
        self.enabled = [enabledValue boolValue];

        // Template values, only care about if enabled is true
        if (self.enabled) {
            NSDictionary *template  = [data objectForKey:MAVERemoteConfigKeyCustomSharePageTemplate];
            self.templateID = [template objectForKey:MAVERemoteConfigKeyCustomSharePageTemplateID];
            self.explanationCopy = [template objectForKey:MAVERemoteConfigKeyCustomSharePageExplanationCopy];
            if (!self.templateID || !self.explanationCopy) {
                return nil;
            }
        }
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    NSString *explanation = [NSString stringWithFormat:@"Share %@ with friends",
                             [MAVEClientPropertyUtils appName]];
    return @{MAVERemoteConfigKeyCustomSharePageEnabled: @YES,
             MAVERemoteConfigKeyCustomSharePageTemplate: @{
                 MAVERemoteConfigKeyCustomSharePageTemplateID: @"0",
                 MAVERemoteConfigKeyCustomSharePageExplanationCopy: explanation,
        }
    };
}

@end
