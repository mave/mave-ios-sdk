//
//  MAVERemoteConfigurationCustomSharePage.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/13/15.
//
//

#import "MAVERemoteConfigurationCustomSharePage.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVETemplatingUtils.h"

const NSString *MAVERemoteConfigKeyCustomSharePageEnabled = @"enabled";
const NSString *MAVERemoteConfigKeyCustomSharePageTemplate = @"template";
const NSString *MAVERemoteConfigKeyCustomSharePageTemplateID = @"template_id";
const NSString *MAVERemoteConfigKeyCustomSharePageExplanationCopy = @"explanation_copy_template";
const NSString *MAVERemoteConfigKeyCustomSharePageInviteLinkBaseURL = @"invite_link_base_url";
const NSString *MAVERemoteConfigKeyCustomSharePageIncludeClientSMS = @"include_client_sms";
const NSString *MAVERemoteConfigKeyCustomSharePageIncludeClientEmail = @"include_client_email";
const NSString *MAVERemoteConfigKeyCustomSharePageIncludeNativeFacebook = @"include_native_facebook";
const NSString *MAVERemoteConfigKeyCustomSharePageIncludeNativeTwitter = @"include_native_twitter";
const NSString *MAVERemoteConfigKeyCustomSharePageIncludeClipboard = @"include_clipboard";


@implementation MAVERemoteConfigurationCustomSharePage

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        // check for is-enabled key. Empty != key explicitly set to false
        id enabledValue = [data objectForKey:MAVERemoteConfigKeyCustomSharePageEnabled];
        if (enabledValue == nil) {
            return nil;
        }
        self.enabled = [enabledValue boolValue];

        NSString *inviteLinkDomain = [data objectForKey:MAVERemoteConfigKeyCustomSharePageInviteLinkBaseURL];
        if (inviteLinkDomain && inviteLinkDomain != (id)[NSNull null]) {
            self.inviteLinkBaseURL = inviteLinkDomain;
        }

        // Template values, only care about if enabled is true
        if (self.enabled) {
            NSDictionary *template  = [data objectForKey:MAVERemoteConfigKeyCustomSharePageTemplate];

            NSString *templateID = [template objectForKey:MAVERemoteConfigKeyCustomSharePageTemplateID];
            if (![templateID isEqual: [NSNull null]]) {
                self.templateID = templateID;
            }

            NSString *explanationCopyTemplate = [template objectForKey:MAVERemoteConfigKeyCustomSharePageExplanationCopy];
            if (![explanationCopyTemplate isEqual:[NSNull null]]) {
                self.explanationCopyTemplate = explanationCopyTemplate;
            }
            if (!self.explanationCopyTemplate) {
                return nil;
            }

            id includeClientSMS = [template objectForKey:MAVERemoteConfigKeyCustomSharePageIncludeClientSMS];
            if (![includeClientSMS isEqual:[NSNull null]]) {
                self.includeClientSMS = [includeClientSMS boolValue];
            }
            id includeClientEmail = [template objectForKey:MAVERemoteConfigKeyCustomSharePageIncludeClientEmail];
            if (![includeClientEmail isEqual:[NSNull null]]) {
                self.includeClientEmail = [includeClientEmail boolValue];
            }
            id includeNativeFacebook = [template objectForKey:MAVERemoteConfigKeyCustomSharePageIncludeNativeFacebook];
            if (![includeNativeFacebook isEqual:[NSNull null]]) {
                self.includeNativeFacebook = [includeNativeFacebook boolValue];
            }
            id includeNativeTwitter = [template objectForKey:MAVERemoteConfigKeyCustomSharePageIncludeNativeTwitter];
            if (![includeNativeTwitter isEqual:[NSNull null]]) {
                self.includeNativeTwitter = [includeNativeTwitter boolValue];
            }
            id includeClipboard = [template objectForKey:MAVERemoteConfigKeyCustomSharePageIncludeClipboard];
            if (![includeClipboard isEqual:[NSNull null]]) {
                self.includeClipboard = [includeClipboard boolValue];
            }
        }
    }
    return self;
}

- (NSString *)explanationCopy {
    return [MAVETemplatingUtils interpolateWithSingletonDataTemplateString:self.explanationCopyTemplate];
}

+ (NSDictionary *)defaultJSONData {
    NSString *explanation = [NSString stringWithFormat:@"Share %@ with friends",
                             [MAVEClientPropertyUtils appName]];
    return @{MAVERemoteConfigKeyCustomSharePageEnabled: @YES,
             MAVERemoteConfigKeyCustomSharePageInviteLinkBaseURL: [NSNull null],
             MAVERemoteConfigKeyCustomSharePageTemplate: @{
                 MAVERemoteConfigKeyCustomSharePageTemplateID: @"0",
                 MAVERemoteConfigKeyCustomSharePageExplanationCopy: explanation,
                 MAVERemoteConfigKeyCustomSharePageIncludeClientSMS: @YES,
                 MAVERemoteConfigKeyCustomSharePageIncludeClientEmail: @YES,
                 MAVERemoteConfigKeyCustomSharePageIncludeNativeFacebook: @YES,
                 MAVERemoteConfigKeyCustomSharePageIncludeNativeTwitter: @YES,
                 MAVERemoteConfigKeyCustomSharePageIncludeClipboard: @YES,
        }
    };
}

@end
