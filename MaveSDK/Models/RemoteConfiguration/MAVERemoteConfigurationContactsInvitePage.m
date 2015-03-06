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
const NSString *MAVERemoteConfigKeyContactsInvitePageSuggestedInvitesEnabled = @"suggested_invites_enabled";
const NSString *MAVERemoteConfigKeyContactsInvitePageSMSSendMethod = @"sms_send_method";
const NSString *MAVERemoteConfigKeyContactsInvitePageSMSSendMethodServerSide = @"server_side";
const NSString *MAVERemoteConfigKeyContactsInvitePageSMSSendMethodClientSideGroup = @"client_side_group";


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
            NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyContactsInvitePageTemplate];

            NSString *templateIDVal = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageTemplateID];
            if (![templateIDVal isEqual:[NSNull null]]) {
                self.templateID = templateIDVal;
            }

            NSString *explanationCopyVal = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageExplanationCopy];
            if (explanationCopyVal != (id)[NSNull null]) {
                self.explanationCopy = explanationCopyVal;
            }

            id suggestedInvitesVal = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageSuggestedInvitesEnabled];
            if (suggestedInvitesVal && (id)suggestedInvitesVal != [NSNull null]) {
                self.suggestedInvitesEnabled = [suggestedInvitesVal boolValue];
            }
            self.smsInviteSendMethod = MAVESMSInviteSendMethodClientSideGroup;
        }
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyContactsInvitePageEnabled: @YES,
        MAVERemoteConfigKeyContactsInvitePageTemplate: @{
            MAVERemoteConfigKeyContactsInvitePageTemplateID: @"0",
            // Explanation copy defaults to nil, so leaving empty
            MAVERemoteConfigKeyContactsInvitePageSuggestedInvitesEnabled: @NO,
        }
    };
}

@end
