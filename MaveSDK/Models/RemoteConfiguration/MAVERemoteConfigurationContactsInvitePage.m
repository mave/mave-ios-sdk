//
//  MAVERemoteConfigurationContactsInvitePage.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/10/15.
//
//

#import "MAVERemoteConfigurationContactsInvitePage.h"
#import "MAVEClientPropertyUtils.h"

const NSString *MAVERemoteConfigKeyContactsInvitePageEnabled = @"enabled";
const NSString *MAVERemoteConfigKeyContactsInvitePageTemplate = @"template";
const NSString *MAVERemoteConfigKeyContactsInvitePageTemplateID = @"template_id";
const NSString *MAVERemoteConfigKeyContactsInvitePageExplanationCopy = @"explanation_copy";
const NSString *MAVERemoteConfigKeyContactsInvitePageSMSCopy = @"sms_copy";


@implementation MAVERemoteConfigurationContactsInvitePage

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        // check for is-enabled key. Empty != key explicitly set to false
        id enabledValue = [data objectForKey:MAVERemoteConfigKeyContactsInvitePageEnabled];
        if (enabledValue == nil) {
            return nil;
        }
        self.enabled = [enabledValue boolValue];

        // Template values, only care about if enabled is true
        if (self.enabled) {
            NSDictionary *template  = [data objectForKey:MAVERemoteConfigKeyContactsInvitePageTemplate];
            self.templateID = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageTemplateID];
            self.explanationCopy = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageExplanationCopy];
            self.smsCopy = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageSMSCopy];
            if (!self.smsCopy) {
                return nil;
            }
        }
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    NSString *smsCopy = [NSString stringWithFormat:@"Join me on %@!",
                         [MAVEClientPropertyUtils appName]];
    return @{
        MAVERemoteConfigKeyContactsInvitePageEnabled: @YES,
        MAVERemoteConfigKeyContactsInvitePageTemplate: @{
            MAVERemoteConfigKeyContactsInvitePageTemplateID: @"0",
            // Explanation key defaults to nil, so leaving empty
            MAVERemoteConfigKeyContactsInvitePageSMSCopy: smsCopy,
        }
    };
}

@end
