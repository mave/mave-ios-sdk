//
//  MAVERemoteConfigurationContactsPrePrompt.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import "MAVERemoteConfigurationContactsPrePrompt.h"


const NSString *MAVERemoteConfigKeyContactsPrePromptTemplateTemplate = @"template";
const NSString *MAVERemoteConfigKeyContactsPrePromptTemplateID = @"template_id";
const NSString *MAVERemoteConfigKeyContactsPrePromptEnabled = @"enabled";
const NSString *MAVERemoteConfigKeyContactsPrePromptTitle = @"title";
const NSString *MAVERemoteConfigKeyContactsPrePromptMessage = @"message";
const NSString *MAVERemoteConfigKeyContactsPrePromptCancelCopy = @"cancel_button_copy";
const NSString *MAVERemoteConfigKeyContactsPrePromptAcceptCopy = @"accept_button_copy";


@implementation MAVERemoteConfigurationContactsPrePrompt

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [self init]) {
        self.enabled = [[data objectForKey:MAVERemoteConfigKeyContactsPrePromptEnabled] boolValue];

        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplateTemplate];
        self.templateID = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplateID];
        self.title = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptTitle];
        self.message = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptMessage];
        self.cancelButtonCopy = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptCancelCopy];
        self.acceptButtonCopy = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptAcceptCopy];
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyContactsPrePromptEnabled: @YES,
        MAVERemoteConfigKeyContactsPrePromptTemplateTemplate: @{
            MAVERemoteConfigKeyContactsPrePromptTemplateID: @"default",
            MAVERemoteConfigKeyContactsPrePromptTitle: @"Access your contacts?",
            MAVERemoteConfigKeyContactsPrePromptMessage:
                @"We need to access your contacts to suggest people to invite.",
            MAVERemoteConfigKeyContactsPrePromptAcceptCopy: @"Sounds good",
            MAVERemoteConfigKeyContactsPrePromptCancelCopy: @"No thanks",
        }
    };
}

@end
