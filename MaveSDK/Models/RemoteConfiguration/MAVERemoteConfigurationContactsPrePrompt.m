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

            NSString *templateID = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplateID];
            if (![templateID isEqual:[NSNull null]]) {
                self.templateID = templateID;
            }
            NSString *title = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptTitle];
            if (![title isEqual:[NSNull null]]) {
                self.title = title;
            }
            NSString *message = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptMessage];
            if (![message isEqual:[NSNull null]]) {
                self.message = message;
            }
            NSString *cancelButtonCopy = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptCancelCopy];
            if (![cancelButtonCopy isEqual:[NSNull null]]) {
                self.cancelButtonCopy = cancelButtonCopy;
            }
            NSString *acceptButtonCopy = [template objectForKey:MAVERemoteConfigKeyContactsPrePromptAcceptCopy];
            if (![acceptButtonCopy isEqual:[NSNull null]]) {
                self.acceptButtonCopy = acceptButtonCopy;
            }
        }
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyContactsPrePromptEnabled: @YES,
        MAVERemoteConfigKeyContactsPrePromptTemplate: @{
            MAVERemoteConfigKeyContactsPrePromptTemplateID: @"0",
            MAVERemoteConfigKeyContactsPrePromptTitle: @"Use address book?",
            MAVERemoteConfigKeyContactsPrePromptMessage:
                @"This allows you to select friends from your address book to invite.",
            MAVERemoteConfigKeyContactsPrePromptAcceptCopy: @"OK",
            MAVERemoteConfigKeyContactsPrePromptCancelCopy: @"Not now",
        }
    };
}

@end
