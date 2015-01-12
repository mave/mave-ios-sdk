//
//  MAVERemoteConfigurationContactsPrePrompt.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import "MAVERemoteConfigurationContactsPrePrompt.h"


const NSString *MAVERemoteConfigKeyContactsPrePromptTemplate = @"template";
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

        // only if it's enabled do we care about the templated options
        if  (self.enabled) {
            NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplate];
            self.templateID = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplateID];
            self.title = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptTitle];
            self.message = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptMessage];
            self.cancelButtonCopy = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptCancelCopy];
            self.acceptButtonCopy = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptAcceptCopy];
        }
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyContactsPrePromptEnabled: @YES,
        MAVERemoteConfigKeyContactsPrePromptTemplate: @{
            MAVERemoteConfigKeyContactsPrePromptTemplateID: @"0",
            MAVERemoteConfigKeyContactsPrePromptTitle: @"Access your contacts?",
            MAVERemoteConfigKeyContactsPrePromptMessage:
                @"We need to access your contacts to suggest people to invite.",
            MAVERemoteConfigKeyContactsPrePromptAcceptCopy: @"Sounds good",
            MAVERemoteConfigKeyContactsPrePromptCancelCopy: @"No thanks",
        }
    };
}

@end
