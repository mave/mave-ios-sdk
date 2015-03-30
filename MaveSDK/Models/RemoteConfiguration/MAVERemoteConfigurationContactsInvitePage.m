//
//  MAVERemoteConfigurationContactsInvitePage.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/10/15.
//
//

#import "MAVERemoteConfigurationContactsInvitePage.h"
#import "MAVEClientPropertyUtils.h"

NSString * const MAVERemoteConfigKeyContactsInvitePageEnabled = @"enabled";
NSString * const MAVERemoteConfigKeyContactsInvitePageTemplate = @"template";
NSString * const MAVERemoteConfigKeyContactsInvitePageTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyContactsInvitePageExplanationCopy = @"explanation_copy";
NSString * const MAVERemoteConfigKeyContactsInvitePageIncludeShareButtons = @"share_buttons_enabled";
NSString * const MAVERemoteConfigKeyContactsInvitePageSuggestedInvitesEnabled = @"suggested_invites_enabled";
NSString * const MAVERemoteConfigKeyContactsInvitePageSMSSendMethod = @"sms_invite_send_method";
NSString * const MAVERemoteConfigKeyContactsInvitePageSMSSendMethodServerSide = @"server_side";
NSString * const MAVERemoteConfigKeyContactsInvitePageSMSSendMethodClientSideGroup = @"client_side_group";


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

            NSNumber *shareButtonsEnabled = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageIncludeShareButtons];
            if (shareButtonsEnabled != (id)[NSNull null]) {
                self.shareButtonsEnabled = [shareButtonsEnabled boolValue];
            }

            id suggestedInvitesVal = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageSuggestedInvitesEnabled];
            if (suggestedInvitesVal && (id)suggestedInvitesVal != [NSNull null]) {
                self.suggestedInvitesEnabled = [suggestedInvitesVal boolValue];
            }
            NSString *smsSendMethod = [template objectForKey:MAVERemoteConfigKeyContactsInvitePageSMSSendMethod];
            if ([smsSendMethod isEqualToString:MAVERemoteConfigKeyContactsInvitePageSMSSendMethodClientSideGroup]) {
                self.smsInviteSendMethod = MAVESMSInviteSendMethodClientSideGroup;
            } else {
                self.smsInviteSendMethod = MAVESMSInviteSendMethodServerSide;
            }
        }
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyContactsInvitePageEnabled: @YES,
        MAVERemoteConfigKeyContactsInvitePageTemplate: @{
            MAVERemoteConfigKeyContactsInvitePageTemplateID: @"0",
            MAVERemoteConfigKeyContactsInvitePageExplanationCopy: [NSNull null],
            MAVERemoteConfigKeyContactsInvitePageIncludeShareButtons: @NO,
            MAVERemoteConfigKeyContactsInvitePageSuggestedInvitesEnabled: @NO,
            MAVERemoteConfigKeyContactsInvitePageSMSSendMethod: MAVERemoteConfigKeyContactsInvitePageSMSSendMethodServerSide,
        }
    };
}

@end
