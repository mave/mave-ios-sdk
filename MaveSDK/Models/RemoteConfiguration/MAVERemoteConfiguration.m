//
//  MAVERemoteConfiguration.m
//  MaveSDK
//
//  Created by Danny Cosson on 12/18/14.
//
//

#import <Foundation/Foundation.h>
#import "MaveSDK.h"
#import "MAVEConstants.h"
#import "MAVERemoteConfiguration.h"
#import "MAVERemoteObjectBuilder.h"
#import "MAVERemoteConfigurationContactsPrePrompt.h"

NSString * const MAVEUserDefaultsKeyRemoteConfiguration = @"MAVEUserDefaultsKeyRemoteConfiguration";

NSString * const MAVERemoteConfigKeyContactsPrePrompt = @"contacts_pre_permission_prompt";
NSString * const MAVERemoteConfigKeyContactsInvitePage =
    @"contacts_invite_page";
NSString * const MAVERemoteConfigKeyClientSMS = @"client_sms";
NSString * const MAVERemoteConfigKeyClientEmail = @"client_email";
NSString * const MAVERemoteConfigKeyFacebookShare = @"facebook_share";
NSString * const MAVERemoteConfigKeyTwitterShare = @"twitter_share";
NSString * const MAVERemoteConfigKeyClipboardShare = @"clipboard_share";


@implementation MAVERemoteConfiguration

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSLog(@"data is: %@", data);
        self.contactsPrePrompt = [[MAVERemoteConfigurationContactsPrePrompt alloc] initWithDictionary:[data objectForKey:MAVERemoteConfigKeyContactsPrePrompt]];

        self.contactsInvitePage = [[MAVERemoteConfigurationContactsInvitePage alloc] initWithDictionary:[data objectForKey:MAVERemoteConfigKeyContactsInvitePage]];

        self.clientSMS = [[MAVERemoteConfigurationClientSMS alloc] initWithDictionary:[data objectForKey:MAVERemoteConfigKeyClientSMS]];

        self.clientEmail = [[MAVERemoteConfigurationClientEmail alloc] initWithDictionary:[data objectForKey:MAVERemoteConfigKeyClientEmail]];

        self.facebookShare = [[MAVERemoteConfigurationFacebookShare alloc] initWithDictionary:[data objectForKey:MAVERemoteConfigKeyFacebookShare]];

        self.twitterShare = [[MAVERemoteConfigurationTwitterShare alloc] initWithDictionary:[data objectForKey:MAVERemoteConfigKeyTwitterShare]];

        self.clipboardShare = [[MAVERemoteConfigurationClipboardShare alloc] initWithDictionary:[data objectForKey:MAVERemoteConfigKeyClipboardShare]];

        if (!self.contactsPrePrompt
            || !self.contactsInvitePage
            || !self.clientSMS
            || !self.clientEmail
            || !self.facebookShare
            || !self.twitterShare
            || !self.clipboardShare) {
            return nil;
        }
    }
    return self;
}

+ (MAVERemoteObjectBuilder *)remoteBuilder {
    return [[MAVERemoteObjectBuilder alloc] initWithClassToCreate:[self class] preFetchBlock:^(MAVEPromise *promise) {
            [[MaveSDK sharedInstance].APIInterface getRemoteConfigurationWithCompletionBlock:^(NSError *error, NSDictionary *responseData) {
                DebugLog(@"RemoteConfiguration data was: %@", responseData);
                 if (error) {
                     [promise rejectPromise];
                 } else {
                     [promise fulfillPromise:(NSValue *)responseData];
                 }
             }];
            } defaultData:[self defaultJSONData]
            saveIfSuccessfulToUserDefaultsKey:MAVEUserDefaultsKeyRemoteConfiguration
            preferLocallySavedData:NO];
}

+ (NSDictionary *)defaultJSONData {
    return @{
        MAVERemoteConfigKeyContactsPrePrompt: [MAVERemoteConfigurationContactsPrePrompt defaultJSONData],
        MAVERemoteConfigKeyContactsInvitePage:[MAVERemoteConfigurationContactsInvitePage defaultJSONData],
        MAVERemoteConfigKeyClientSMS: [MAVERemoteConfigurationClientSMS defaultJSONData],
        MAVERemoteConfigKeyClientEmail: [MAVERemoteConfigurationClientEmail defaultJSONData],
        MAVERemoteConfigKeyFacebookShare: [MAVERemoteConfigurationFacebookShare defaultJSONData],
        MAVERemoteConfigKeyTwitterShare: [MAVERemoteConfigurationTwitterShare defaultJSONData],
        MAVERemoteConfigKeyClipboardShare: [MAVERemoteConfigurationClipboardShare defaultJSONData],
    };
}

@end
