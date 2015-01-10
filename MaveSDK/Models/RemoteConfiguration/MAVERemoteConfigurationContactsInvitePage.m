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
        self.enabled = [[data objectForKey:MAVERemoteConfigKeyContactsInvitePageEnabled] boolValue];
        NSDictionary *template  = [data objectForKey:MAVERemoteConfigKeyContactsInvitePageTemplate];
        self.templateID = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageTemplateID];
        self.explanationCopy = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageExplanationCopy];
        self.smsCopy = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageSMSCopy];
    }
    return self;
}


+ (NSDictionary *)defaultJSONData {
    NSString *smsCopy = [NSString stringWithFormat:@"Join me on %@!",
                         [MAVEClientPropertyUtils appName]];
    return @{
        MAVERemoteConfigKeyContactsInvitePageEnabled: @YES,
        MAVERemoteConfigKeyContactsInvitePageTemplate: @{
            MAVERemoteConfigKeyContactsInvitePageTemplateID: @"default",
            // Explanation key defaults to nil, so leaving empty
            MAVERemoteConfigKeyContactsInvitePageSMSCopy: smsCopy,
        }
    };
}

@end
