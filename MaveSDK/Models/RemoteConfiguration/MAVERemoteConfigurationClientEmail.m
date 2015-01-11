//
//  MAVERemoteConfigurationClientEmail.m
//  MaveSDK
//
//  Created by Danny Cosson on 1/11/15.
//
//

#import "MAVERemoteConfigurationClientEmail.h"
#import "MAVEClientPropertyUtils.h"

NSString * const MAVERemoteConfigKeyClientEmailTemplate = @"template";
NSString * const MAVERemoteConfigKeyClientEmailTemplateID = @"template_id";
NSString * const MAVERemoteConfigKeyClientEmailSubject = @"subject";
NSString * const MAVERemoteConfigKeyClientEmailBody = @"body";

@implementation MAVERemoteConfigurationClientEmail

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSDictionary *template = [data objectForKey:MAVERemoteConfigKeyClientEmailTemplate];
        self.templateID = [template objectForKey:MAVERemoteConfigKeyClientEmailTemplateID];
        self.subject = [template objectForKey:MAVERemoteConfigKeyClientEmailSubject];
        self.body = [template objectForKey:MAVERemoteConfigKeyClientEmailBody];
        if (!self.templateID || !self.subject || !self.body) {
            return nil;
        }
    }
    return self;
}

+ (NSDictionary *)defaultJSONData {
    NSString *subject = [NSString stringWithFormat:@"Join %@",
                         [MAVEClientPropertyUtils appName]];
    NSString *body = [NSString stringWithFormat:@"Hey, I've been using %@ and thought you might like it. Check it out:\n\n",
                      [MAVEClientPropertyUtils appName]];
    return  @{
        MAVERemoteConfigKeyClientEmailTemplate: @{
            MAVERemoteConfigKeyClientEmailTemplateID: @"0",
            MAVERemoteConfigKeyClientEmailSubject: subject,
            MAVERemoteConfigKeyClientEmailBody: body,
        }
    };
}

@end
