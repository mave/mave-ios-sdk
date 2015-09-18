//
//  MAVERemoteConfigurationServerSMS.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/14/15.
//
//

#import "MAVERemoteConfigurationServerSMS.h"
#import "MAVEClientPropertyUtils.h"
#import "MAVETemplatingUtils.h"
#import "MaveSDK.h"
#import "MAVEConstants.h"

NSString * const MAVERemoteConfigKeyServerSMSTemplate = @"template";
NSString * const MAVERemoteConfigKeyServerSMSTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyServerSMSCopy = @"copy_template";
NSString * const MAVERemoteConfigKeyServerSMSCountryCodes = @"country_codes";


@implementation MAVERemoteConfigurationServerSMS

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyServerSMSTemplate];

        NSString *templateID = [template objectForKey:MAVERemoteConfigKeyServerSMSTemplateID];
        if (![templateID isEqual:[NSNull null]]) {
            self.templateID = templateID;
        }
        NSString *text = [template objectForKey:MAVERemoteConfigKeyServerSMSCopy];
        if (![text isEqual:[NSNull null]]) {
            self.textTemplate = text;
        }
        if (!self.textTemplate) {
            return nil;
        }

        NSArray *countryCodes = [template objectForKey:MAVERemoteConfigKeyServerSMSCountryCodes];
        if (countryCodes && ![countryCodes isEqual: [NSNull null]]) {
            self.countryCodes = [[NSSet alloc] initWithArray:countryCodes];
        } else {
            self.countryCodes = [[NSSet alloc] init];
        }

    }
    return self;
}

// Returns the sms copy with template values filled in
- (NSString *)text {
    // fill in link var with itself, to let the it pass through since the
    // link needs to be filled in on the server for server-side sms.
    //
    // Note we don't append {{ link }} to the end, if there's no {{ link }}
    // explicitly in the template it doesn't get put in. This lets the
    // user-editable message invite pages (V1 & V2) continue working by
    // just not using that template variable. The server will append a
    // link if the text it receives has no {{ link }} var.
    MAVEUserData *user = [MaveSDK sharedInstance].userData;
    return [MAVETemplatingUtils interpolateTemplateString:self.textTemplate withUser:user link:@"{{ link }}"];
}

+ (NSDictionary *)defaultJSONData {
    NSString *text = [NSString stringWithFormat:@"Join me on %@!",
                      [MAVEClientPropertyUtils appName]];
    return @{
             MAVERemoteConfigKeyServerSMSTemplate: @{
                     MAVERemoteConfigKeyServerSMSTemplateID: @"0",
                     MAVERemoteConfigKeyServerSMSCopy: text,
                     MAVERemoteConfigKeyServerSMSCountryCodes: @[
                             MAVECountryCodeUnitedStates, MAVECountryCodeCanada],
                     },
             
             };
}

@end
