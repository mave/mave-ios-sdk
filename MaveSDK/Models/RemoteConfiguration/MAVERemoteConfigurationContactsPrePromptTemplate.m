//
//  MAVERemoteConfigurationContactsPrePromptTemplate.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import "MAVERemoteConfigurationContactsPrePromptTemplate.h"


const NSString *MAVERemoteConfigKeyContactsPrePromptTemplateID = @"template_id";
const NSString * MAVERemoteConfigKeyContactsPrePromptEnabled = @"enabled";
const NSString *MAVERemoteConfigKeyContactsPrePromptTemplateTitle = @"title";
const NSString *MAVERemoteConfigKeyContactsPrePromptTemplateMessage = @"message";
const NSString *MAVERemoteConfigKeyContactsPrePromptTemplateCancelCopy = @"cancel_button_copy";
const NSString *MAVERemoteConfigKeyContactsPrePromptTemplateAcceptCopy = @"accept_button_copy";


@implementation MAVERemoteConfigurationContactsPrePromptTemplate

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [self init]) {
        self.templateID = [data objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplateID];
        self.enabled = [[data objectForKey:MAVERemoteConfigKeyContactsPrePromptEnabled] boolValue];
        self.title = [data objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplateTitle];
        self.message = [data objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplateMessage];
        self.cancelButtonCopy = [data objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplateCancelCopy];
        self.acceptButtonCopy = [data objectForKey:MAVERemoteConfigKeyContactsPrePromptTemplateAcceptCopy];
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyContactsPrePromptEnabled: @YES,
        MAVERemoteConfigKeyContactsPrePromptTemplateID: @"default",
        MAVERemoteConfigKeyContactsPrePromptTemplateTitle: @"Access your contacts?",
        MAVERemoteConfigKeyContactsPrePromptTemplateMessage:
            @"We need to access your contacts to suggest people to invite.",
        MAVERemoteConfigKeyContactsPrePromptTemplateAcceptCopy: @"Sounds good",
        MAVERemoteConfigKeyContactsPrePromptTemplateCancelCopy: @"No thanks",
    };
}

@end
